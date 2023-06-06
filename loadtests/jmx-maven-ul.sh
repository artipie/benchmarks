#!/bin/bash -e

if [ $# -ne 4 ]; then 
    echo "Usage: $0 host port duration (maven-dyn|maven-real)" && exit 1
fi

host="$1"
port="$2"
duration="$3"
repo="$4"

cd `dirname "$0"`

repoDir="test-data/$repo"
if [ ! -d "$repoDir" ] ; then
    echo "$repoDir data directory not found. Prepare data first!" && exit 2
fi

jmeter="./apache-jmeter-5.5/bin/jmeter"

echo "Remove old results"
testDir="artipie_test_res"
lastDir="last_test_result"
rm -rf "$testDir"
rm -f "$lastDir"
rm -f artipie-upload.log
mkdir "$testDir"

echo "Run jmeter tests"
"$jmeter" -n -t ./upload-maven-csv.jmx -l ./artipie-upload.log -e -o "$testDir" -Jrepository.host="$host" -Jrepository.port="$port" \
  -Jrepository.path=maventest -Jduration="$duration" -Jsrc.path=$repoDir/repository -Jsrc.list=$repoDir/files-list.csv
resDir="maven_ul_${host}_${port}_${duration}_$(date +%y-%m-%d_%H-%M-%S)"
mv -f "$testDir" "$resDir"
ln -s "$resDir" "$lastDir"
./checkstats.py "./$lastDir/statistics.json" 10
