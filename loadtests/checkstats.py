#!/usr/bin/env python3
"""
Checks that `statistics.json` has error percentage below provided threshold.
Usage:
./checkstats.py ./last_test_result/statistics.json 5.0
./checkstats.py ./path/to/perftests_repo/perftests 10.0
"""
import os
import pathlib
import sys
import json
from pathlib import Path
from packaging import version

if __name__ == '__main__':
    limit = float(sys.argv[2])
    if os.path.isdir(sys.argv[1]):
        perftestsDir = sys.argv[1]
        testGroups = {}
        for root, dirs, files in os.walk(perftestsDir):
            for f in files:
                if f == "statistics.json":
                    statsFile = Path(root, f)
                    testName = statsFile.parts[-2]
                    statResults = testGroups.setdefault(testName, [])
                    statResults.append(statsFile)
        for name, stats in testGroups.items():
            #print(name, stats)
            stats.sort(key = lambda x: version.parse(x.parts[-3])) #sort by tag as version
        #print(testGroups)
        tags = os.listdir(perftestsDir)
        tags.sort(key = lambda x: version.parse(x)) #sort by tag as version
        tags = tags[-2:]
        print(tags)
        if len(tags) < 2:
            print('Error: not enough tags found!')
            exit(1)
        tests = os.listdir(f"{perftestsDir}/{tags[0]}")
        for test in tests:
            pathA = f"{perftestsDir}/{tags[0]}/{test}/statistics.json"
            pathB = f"{perftestsDir}/{tags[1]}/{test}/statistics.json"
            with open(pathA, "rb") as fileA, open(pathB, "rb") as fileB:
                jsonA = json.load(fileA)
                jsonB = json.load(fileB)
                trA = float(jsonA['Total']['throughput'])
                mrtA = float(jsonA['Total']['meanResTime'])
                trB = float(jsonB['Total']['throughput'])
                mrtB = float(jsonB['Total']['meanResTime'])
                throughputDiff = abs(1.0 - trB / trA) * 100.0
                meanResTimeDiff = abs(1.0 - mrtB / mrtA) * 100.0
                print(test, pathA, pathB)
                print(test, trA, mrtA)
                print(test, trB, mrtB)
                print(test, throughputDiff, meanResTimeDiff)
                if throughputDiff > limit or meanResTimeDiff > limit:
                    print(f"Error: result difference is more than a limit {limit}!")
                    exit(2)
        exit(0)
    else:
        with open(sys.argv[1], "rb") as f:
            json: dict = json.load(f)
            errorPct = float(json['Total']['errorPct'])
            exit(0 if errorPct < limit else 1)
