#!/bin/bash -e
# Generates .jml file + .html report; Non-GUI mode.
#https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-5.5.tgz
if [ $# -ne 2 ]; then 
    echo "Usage: $0 path/to/file.jmx out/dir" && exit 1
fi
baseDir="$(dirname "$0")"
jmeter="$baseDir/apache-jmeter-5.5/bin/jmeter"
out="$2/$(basename "$1")"
outJtl="${out}.jtl"
rm -rf "$outJtl"
rm -rf "$out"
mkdir -p "$out"
"$jmeter" -n -t "$1" -l "$outJtl" -e -o "$out"

