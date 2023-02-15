#!/usr/bin/env python3
"""
Configurable maven test data generator
Usage::
    ./gen-maven.py groups artifacts versions big_size med_size small_size bigs_percent smalls_percent
"""

from io import TextIOBase
import os
import shutil
import pathlib
import signal
import sys
import tempfile
import subprocess
import time

g_termination = False

def generateRepo(dstRepo: str, srv: subprocess.Popen, groups, artifacts, versions, bigSize, medSize, smallSize, bigP, smallP):
    BIG = 'big'
    MED = 'med'
    SMALL = 'small'

    totals = int(groups * artifacts * versions)
    bigs = int(totals * bigP / 100)
    smalls = int(totals * smallP / 100)
    mediums = int(totals - bigs - smalls)
    if totals <= 0 or mediums < 0:
        print(f"Error. Incorrent artifacts counts: {totals}; {bigs}; {mediums}; {smalls}", file=sys.stderr)
        exit(1)

    print(f"Limits: {totals}; {bigs}; {smalls}, {mediums}")

    groupsSizes = {BIG: bigSize, MED: medSize, SMALL: smallSize}
    groupsUploaded = {BIG: 0, MED: 0, SMALL: 0}
    groupsLimits = {BIG: bigs, MED: mediums, SMALL: smalls}

    totalUploaded = 0
    for gr in range(1, groups + 1):
        for ar in range(1, artifacts + 1):
            for ver in range(1, versions + 1):
                for x in groupsSizes.keys():
                    if g_termination or srv.poll() != None:
                        return
                    if groupsUploaded[x] < groupsLimits[x]:
                        generateArtifact(dstRepo, f"group{gr}", f"artifact{ar}-{x}", f"1.{ver}.0", groupsSizes[x])
                        groupsUploaded[x] += 1
                        totalUploaded += 1
                        break #one new artifact per version 
                    else:
                        print(f"!!!Limit for {x} with count: {groupsUploaded[x]}; {gr} {ar} {ver}")
    print(os.listdir('.'), totalUploaded, groupsUploaded)

def generateArtifact(dstRepo, group, artifact, version, jarSize):
    print('Generation of artifact: ', group, artifact, version, dstRepo, jarSize)
    os.makedirs("META-INF/res", exist_ok = True)
    pathlib.Path("META-INF/MANIFEST.MF").write_text("Manifest-Version: 1.0")
    with open("META-INF/res/random.data", "wb") as f:
        f.write(os.urandom(jarSize))
    jarfile = shutil.make_archive("res", "zip", "META-INF")
    jarfile = shutil.move(jarfile, f"{jarfile}.jar")
    os.system(
          f"mvn -V deploy:deploy-file -Dmaven.wagon.http.ssl.insecure=true -Durl={dstRepo} "
          f"-Dfile={jarfile} -DgroupId={group} -DartifactId={artifact} -Dversion={version}"
        )
    shutil.rmtree("META-INF")
    os.unlink(jarfile)

def sig_handler(_signo, _stack_frame):
    # Raises SystemExit(0):
    global g_termination
    print('TERMINATING...')
    g_termination = True
    sys.exit(-1)

def generateListing(dstDir, dstList):
    with open(dstList, "wt") as filesList:
        oldcwd = os.getcwd()
        os.chdir(dstDir)
        for root, dirs, files in os.walk('.'):
            dir = root[2:] if root.startswith('./') else root
            for f in files:
                print(f"{dir}/{f}", file=filesList)
        os.chdir(oldcwd)

if __name__ == '__main__':
    from sys import argv
    if len(argv) == 9: # time ./prep-maven-dyn.py 4 5 6 9000000 192000 16386 5 30
        groups = int(argv[1])
        artifacts = int(argv[2])
        versions = int(argv[3])
        bigSize = int(argv[4])
        medSize = int(argv[5])
        smallSize = int(argv[6])
        bigP = int(argv[7])
        smallP = int(argv[8])
    else:
        print(f"Usage: {argv[0]} groups artifacts versions big_size med_size small_size bigs_percent smalls_percent")
        exit(1)

    signal.signal(signal.SIGTERM, sig_handler)
    signal.signal(signal.SIGINT, sig_handler)
    
    SRV_PORT = 8002
    DST_REPO = f"http://localhost:{SRV_PORT}"
    baseDir = os.path.dirname(__file__)
    pythonServer = f"{baseDir}/SimpleHTTPPutServer.py"
    dstDir = f"{baseDir}/test-data/maven-dyn/repository"
    dstList = f"{baseDir}/test-data/maven-dyn/files-list.csv"

    if shutil.which('mvn') == None:
        print('mvn is required!', file=sys.stderr)
        exit(1)

    if os.path.exists(pythonServer) == False:
        print(f"{pythonServer} is required!", file=sys.stderr)
        exit(2)

    shutil.rmtree(dstDir, ignore_errors = True)
    pathlib.Path(dstDir).mkdir(parents = True, exist_ok = True)
    srv = subprocess.Popen([sys.executable, pythonServer, str(SRV_PORT)], cwd = dstDir)
    time.sleep(0.5)
    if srv.poll() != None:
        print(f"Failed to start {pythonServer}, return code: {srv.returncode}", file=sys.stderr)
        srv.terminate()
        exit(3)

    tmpRepo = tempfile.mkdtemp()
    os.chdir(tmpRepo)
    try:
        generateRepo(DST_REPO, srv, groups, artifacts, versions, bigSize, medSize, smallSize, bigP, smallP)
        generateListing(dstDir, dstList)
    finally:
        shutil.rmtree(tmpRepo)
        srv.terminate()
