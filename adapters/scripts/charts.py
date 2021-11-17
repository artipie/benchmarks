import argparse
import matplotlib.pyplot as plt
from writeresults import SCAN_PATH, RESULTS, VERSION, TABLE_COL, NO_RES, PLUS_MINUS
from os.path import join


parser = argparse.ArgumentParser(description='Script for plotting charts with JMH benchmarks results')
ALL_CHARTS = -1


def number_of_charts():
    parser.add_argument('number', type=int,
                        help='Number charts - for what number of versions the charts will be plotted',
                        nargs='?',
                        default=ALL_CHARTS)
    args = parser.parse_args()
    return args.number


if __name__ == '__main__':
    num_charts = number_of_charts()
    rows = {}
    map_col = {}
    with open(join(SCAN_PATH, RESULTS), 'r', encoding='utf-8') as f:
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
        plt.savefig(f'{col}.png')
        plt.close()
