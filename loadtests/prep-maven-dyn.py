#!/usr/bin/env python3
"""
Configurable maven test data generator. Usage:
./prep-maven-dyn.py --help
./prep-maven-dyn.py --total-artifacts 100
./prep-maven-dyn.py --groups 3 --artifacts 4 --versions=5
"""

import os
import shutil
import pathlib
import signal
import sys
import tempfile
import subprocess
import time
import argparse
import hashlib
from dataclasses import dataclass
import zipfile

@dataclass
class RepoConfig:
    '''
    Dynamic repository generation config
    '''
    totals: int
    groups: int
    artifacts: int
    versions: int
    bigSize: int
    medSize: int
    smallSize: int
    bigP: int
    mediumP: int

g_termination = False

def generateRepo(dstRepo: str, dstDir: str, srv: subprocess.Popen, cfg: RepoConfig):
    BIG = 'big'
    MED = 'med'
    SMALL = 'small'

    bigs = int(cfg.totals * cfg.bigP / 100)
    mediums = int(cfg.totals * cfg.mediumP / 100)
    smalls = int(cfg.totals - bigs - mediums)
    if cfg.bigP + cfg.mediumP > 100:
        print(f"Error. bigs percent ({cfg.bigP}) + mediums percent ({cfg.mediumP}) can't be more than 100", file=sys.stderr)
        exit(1)
    if cfg.totals <= 0 or smalls < 0:
        print(f"Error. Incorrent artifacts counts. Check groups/artifacts/versions parameters. \n"
              f"Total artifact count: {cfg.totals}; bigs={bigs}; mediums={mediums}; smalls={smalls}", file=sys.stderr)
        exit(1)

    print(f"Limits: totals={cfg.totals}; bigs={bigs}; mediums={mediums}; smalls={smalls}")

    groupsSizes = {BIG: cfg.bigSize, MED: cfg.medSize, SMALL: cfg.smallSize}
    groupsUploaded = {BIG: 0, MED: 0, SMALL: 0}
    groupsLimits = {BIG: bigs, MED: mediums, SMALL: smalls}

    totalUploaded = 0
    for gr in range(1, cfg.groups + 1):
        for ar in range(1, cfg.artifacts + 1):
            for ver in range(1, cfg.versions + 1):
                for x in groupsSizes.keys():
                    if g_termination or srv.poll() != None:
                        return
                    if groupsUploaded[x] < groupsLimits[x]:
                        generateArtifact_fast(dstDir, f"group{gr}", f"artifact{ar}-{x}", f"1.{ver}.0", groupsSizes[x])
                        #generateArtifact_MVN(dstRepo, f"group{gr}", f"artifact{ar}-{x}", f"1.{ver}.0", groupsSizes[x])
                        groupsUploaded[x] += 1
                        totalUploaded += 1
                        break #one new artifact per version 
                    else:
                        print(f"  limit for {x} with count: {groupsUploaded[x]}; {gr} {ar} {ver}; totalUploaded={totalUploaded}")
                if totalUploaded >= cfg.totals:
                    return

def generateArtifact_fast(dstDir, group, artifact, version, jarSize):
    print('Generation of artifact: ', group, artifact, version, dstDir, jarSize)
    workdir = "tmp"
    os.makedirs(f"{workdir}/META-INF/res", exist_ok = True)
    pathlib.Path(f"{workdir}/META-INF/MANIFEST.MF").write_text("Manifest-Version: 1.0")
    with open(f"{workdir}/META-INF/res/random.data", "wb") as f:
        f.write(os.urandom(jarSize))
    oldcwd = os.getcwd()
    os.chdir(workdir)
    zipFile = f"{oldcwd}/res.zip"
    with zipfile.ZipFile(zipFile, "w", zipfile.ZIP_DEFLATED, compresslevel=1) as zf:
        for root, _, filenames in os.walk('.'):
            for name in filenames:
                name = os.path.join(root, name)
                name = os.path.normpath(name)
                zf.write(name, name)
    os.chdir(oldcwd)
    artifactDir = f"{dstDir}/{group}/{artifact}/{version}"
    os.makedirs(artifactDir, exist_ok = True)
    jarFile = f"{artifactDir}/{artifact}-{version}.jar"
    pomFile = f"{artifactDir}/{artifact}-{version}.pom"
    shutil.move(zipFile, jarFile)
    with open(pomFile, "wt") as pom:
        print(
f"""<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <modelVersion>4.0.0</modelVersion>
    <groupId>{group}</groupId>
    <artifactId>{artifact}</artifactId>
    <version>{version}</version>
</project>
""", file=pom)
    shutil.rmtree(workdir)
    generateHashes(jarFile)
    generateHashes(pomFile)

def generateHashes(targetFile: str):
    BUF_SIZE = 256 * 1024
    md5 = hashlib.md5()
    sha1 = hashlib.sha1()
    with open(targetFile, 'rb') as f:
        while True:
            data = f.read(BUF_SIZE)
            if not data:
                break
            md5.update(data)
            sha1.update(data)
    pathlib.Path(f"{targetFile}.md5").write_text(f"{md5.hexdigest()}")
    pathlib.Path(f"{targetFile}.sha1").write_text(f"{sha1.hexdigest()}")
    
def generateArtifact_MVN(dstRepo, group, artifact, version, jarSize):
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
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--total-artifacts', type=int, help='Specify tatal artifacts count. May override groups/artifacts/versions count.', required=False)
    parser.add_argument('--groups', type=int, default=3, help='Count of maven groups to generate')
    parser.add_argument('--artifacts', type=int, default=4, help='Count of maven artifacts to generate')
    parser.add_argument('--versions', type=int, help='Count of maven artifact (sub)versions to generate')
    parser.add_argument('--big-size', type=int, default=9000000, help='Size of "big" artifact type in bytes')
    parser.add_argument('--medium-size', type=int, default=192000, help='Size of "medium" artifact type in bytes')
    parser.add_argument('--small-size', type=int, default=16384, help='Size of "small" artifact type in bytes')
    parser.add_argument('--big-p', type=int, default=5, help='Percent of "big" artifacts (jars) to generate')
    parser.add_argument('--medium-p', type=int, default=80, help='Percent of "medium" sized artifacts. The rest will be "small" sized.')
    args = parser.parse_args()
    if args.total_artifacts:
        args.versions = int(args.total_artifacts / args.groups / args.artifacts)
    elif args.groups == None or args.artifacts == None or args.versions == None:
        parser.print_help()
        exit(1)
    else:
        args.total_artifacts = args.groups * args.artifacts * args.versions
    print(args)

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
        cfg = RepoConfig(args.total_artifacts, args.groups, args.artifacts, args.versions, args.big_size, args.medium_size, args.small_size, args.big_p, args.medium_p)
        generateRepo(DST_REPO, dstDir, srv, cfg)
        generateListing(dstDir, dstList)
    finally:
        shutil.rmtree(tmpRepo)
        srv.terminate()
