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
rm -rf artipie-upload-res
rm -f artipie-upload.log
mkdir artipie-upload-res

echo "Run jmeter tests"
"$jmeter" -n -t ./download-maven-csv.jmx -l ./artipie-upload.log -e -o ./artipie-upload-res -Jrepository.host="$host" -Jrepository.port="$port" \
  -Jrepository.path=chgen/maventest -Jduration="$duration" -Jsrc.path=$repoDir/repository -Jsrc.list=$repoDir/files-list.csv
mv -f artipie-upload.log artipie-upload-res
mv -f artipie-upload-res "maven_dl_${host}_${port}_${duration}_$(date +%y-%m-%d_%H-%M-%S)"
