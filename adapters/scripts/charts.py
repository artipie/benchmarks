import argparse
import matplotlib.pyplot as plt
from writeresults import VERSION, TABLE_COL, NO_RES, PLUS_MINUS
from os import sep
from os.path import join


ALL_CHARTS = -1


parser = argparse.ArgumentParser(description='Script for parsing JMH benchmarks results')


def add_args():
    parser.add_argument('name', type=str,
                        help='A required argument - name of the repository')
    parser.add_argument('number', type=int,
                        help='Number charts - for what number of versions the charts will be plotted',
                        nargs='?',
                        default=ALL_CHARTS)
    parser.add_argument('output', type=str,
                        nargs='?',
                        help='An optional argument - path to the output file with table with results')


if __name__ == '__main__':
    add_args()
    args = parser.parse_args()
    num_charts = args.number
    res_tbl = args.output
    repo_name = args.name
    if res_tbl is None:
        res_tbl = join(sep, 'tmp', 'artipie-bench', repo_name, 'benchmarks', 'results', 'results.md')
    rows = {}
    map_col = {}
    with open(res_tbl, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        for line in lines:
            if line.startswith(f'|{VERSION}') or line.startswith(f'| {VERSION}'):
                # Remembers names of the columns of the table with results
                for idx, name in enumerate(line.split('|')[1:]):
                    name = name.strip()
                    if len(name) > 0:
                        rows[name] = []
                        map_col[idx] = name
            elif line.startswith('|'):
                # Remembers existed results according to columns
                for idx, val in enumerate(line.split('|')[1:]):
                    val = val.strip()
                    if val == NO_RES:
                        val = '0'
                    if len(val) > 0 and val != TABLE_COL:
                        val = val.split(PLUS_MINUS)[0]
                        rows[map_col[idx]].append(val)
    versions = rows.pop(VERSION)
    cols = list(rows.keys())
    font = dict(fontsize=12)
    for col in cols:
        vals = list(map(float, rows[col]))
        if num_charts != ALL_CHARTS and len(vals) > num_charts:
            vals = vals[-num_charts:]
        x = range(len(vals))
        plt.bar(range(len(vals)), vals, width=0.9)
        plt.title(f'Result of benchmarks for operation `{col}`', fontdict=font)
        for index, val in enumerate(vals):
            plt.text(x=index - 0.1, y=val + 0.03, s=f"{val}", fontdict=dict(fontsize=10))
        plt.xticks(x, versions)
        plt.xlabel('Versions', fontdict=font)
        plt.ylabel('ms / op', fontdict=font)
        plt.grid()
        img_name = join('out', repo_name, col)
        print(img_name)
        plt.savefig(f'{img_name}.png')
        plt.close()
