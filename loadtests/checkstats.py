#!/usr/bin/env python3
"""
Checks that `statistics.json` has error percentage below provided threshold.
Usage:
./checkstats.py ./last_test_result/statistics.json 5.0
"""

import sys
import json

if __name__ == '__main__':
    with open(sys.argv[1], "rb") as f:
        limit = float(sys.argv[2])
        json: dict = json.load(f)
        errorPct = float(json['Total']['errorPct'])
        exit(0 if errorPct < limit else 1)
