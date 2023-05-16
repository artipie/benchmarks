#!/bin/bash -e

if [ $# -lt 3 ]; then # just ignore extra args
    echo "Usage: $0 host port duration" && exit 1
fi

host="$1"
port="$2"
duration="$3"

cd `dirname "$0"`

jmeter="./apache-jmeter-5.5/bin/jmeter"

echo "Remove old results"
testDir="artipie_test_res"
lastDir="last_test_result"
rm -rf "$testDir"
rm -f "$lastDir"
rm -f artipie-upload.log
mkdir "$testDir"

echo "Run jmeter tests"
"$jmeter" -n -t ./test-data/files-dyn/download-files-csv.jmx -l ./artipie-upload.log -e -o "$testDir" -Jrepository.host="$host" -Jrepository.port="$port" \
  -Jrepository.path=chgen/bintest -Jduration="$duration" -Jsrc.path=tmp -Jsrc.list=test-data/files-dyn/files-list.csv
resDir="files_dl_${host}_${port}_${duration}_$(date +%y-%m-%d_%H-%M-%S)"
mv -f "$testDir" "$resDir"
ln -s "$resDir" "$lastDir"
