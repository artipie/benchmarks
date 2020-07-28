#!/usr/bin/python3

import os
import subprocess
import collections
import json


def dict_merge(dct, merge_dct):
    """ Recursive dict merge.
    :param dct: dict onto which the merge is executed
    :param merge_dct: dct merged into dct
    :return: None
    """
    for key, value in merge_dct.items():
        if (key in dct and isinstance(dct[key], dict)
                and isinstance(merge_dct[key], collections.Mapping)):
            dict_merge(dct[key], merge_dct[key])
        else:
            dct[key] = merge_dct[key]


# Directories included into benchmarking suit
directories = ["sample"]

# JSON data, containing all the benchmarking results
result = {}

# Run benchmarks for each directory and collect everything into a single JSON
for directory in directories:
    os.chdir(directory)
    subprocess.run(["bash", "-x", "run.sh"])
    file = open("benchmark-results.json", "r")
    dict_merge(json.loads(file.read()), result)
    file.close()
    os.chdir("..")

# Write result into a file
json_str = json.dumps(result)
file = open("benchmark-results.json", "w+")
file.write(json_str)
file.close()
# Fill Github Action output variable
subprocess.run(["echo", f"::set-output name=report::benchmark-results.json"])
