# It is supposed that results are located in folder `scan_path`.
# Each result represents a folder with name which is equal to version.
# After commiting some results it walks through folder with specified
# version in `scan_path` and appends results to the results file.
# It is important that table with results is located in the bottom of the
# results file. Also only lines with result tables should start with the
# symbol `|`.

import argparse
from os import sep, listdir
from os.path import isfile, join, exists

parser = argparse.ArgumentParser(description='Script for parsing JMH benchmarks results')
PLUS_MINUS = '±'
VERSION = 'Version'
TABLE_COL = ':---:'
IMG_FLDR = None
NO_RES = '-'


def add_args():
    parser.add_argument('version', type=str,
                            help='A required argument - version of the release')
    parser.add_argument('name', type=str,
                            help='A required argument - name of the repository')
    parser.add_argument('output', type=str,
                            nargs='?',
                            help='An optional argument - path to the output file with table with results')


def add_results(files, res):
    for file in files:
        with open(join(path, file), 'r') as f:
            lines = f.readlines()
            for line in lines:
                # Extracts result from file required line
                if PLUS_MINUS in line and '.run' in line:
                    words = line.split()
                    idx = -1
                    for idx, word in enumerate(words):
                        if PLUS_MINUS in word:
                            break
                    if idx == -1:
                        raise RuntimeError(f'Failed to find line with results in the `{file}`')
                    res[file.split('.')[0]] = ''.join([words[idx - 1], PLUS_MINUS, words[idx + 1]])


if __name__ == '__main__':
    add_args()
    args = parser.parse_args()
    vers = args.version
    res_tbl = args.output
    name = args.name
    if res_tbl is None:
        res_tbl = join(sep, 'tmp', 'artipie-bench', name, 'benchmarks', 'results', 'results.md')
    path = join('out', name)
    res = {VERSION: vers}
    files = [f for f in listdir(path) if isfile(join(path, f))]
    add_results(files, res)
    res = dict(sorted(res.items()))
    all = {}
    map_col = {}
    if exists(res_tbl):
        with open(res_tbl, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    with open(res_tbl, 'w', encoding='utf-8') as f:
        for line in lines:
            if line.startswith(f'|{VERSION}') or line.startswith(f'| {VERSION}'):
                # Remembers names of the columns of the table with results
                for idx, name in enumerate(line.split('|')[1:]):
                    name = name.strip()
                    if len(name) > 0:
                        all[name] = []
                        map_col[idx] = name
            elif line.startswith('|'):
                # Remembers existed results according to columns
                for idx, val in enumerate(line.split('|')[1:]):
                    val = val.strip()
                    if len(val) > 0:
                        all[map_col[idx]].append(val)
            else:
                f.write(line)

        # Align column names (some columns can be added or disappear)
        # Were some columns removed (e.g. results of benchmarks were not obtained)?
        for old in (all.keys() - res.keys()):
            res[old] = NO_RES
        # If there is not a table with benchmarks results
        if VERSION not in all:
            all[VERSION] = [TABLE_COL]
        # Were some columns added?
        for added in (res.keys() - all.keys()):
            if added != VERSION:
                all[added] = [NO_RES] * len(all[VERSION])
                all[added][0] = TABLE_COL
        # Adds values from the result
        for key in res.keys():
            if key in all:
                all[key].append(res[key])
            else:
                all[key] = [res[key]]
        cols = list(all.keys())
        cols.remove(VERSION)
        # Adds lines to the file with results
        names = '|'.join(cols)
        f.write(f'|{VERSION}|{names}|\n')
        for i in range(len(all[VERSION])):
            line = f'|{all[VERSION][i]}|'
            for col in cols:
                line += f'{all[col][i]}|'
            f.write(f'{line}\n')
