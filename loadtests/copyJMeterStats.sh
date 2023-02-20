#!/bin/bash

if [ $# -lt 2 ]; then 
    echo "Usage: $0 dst_dir src_dir1 ...." && exit 1
fi
dstDir="$1"
shift 1

echo "dst dir: $dstDir"


for var in "$@"
do
    cp -fv "$var/statistics.json" "$dstDir/$(basename $var).json"
done

