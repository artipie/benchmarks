#!/bin/bash -e

if [ $# -ne 3 ]; then 
    echo "Usage: $0 host port duration" && exit 1
fi

host="$1"
port="$2"
duration="$3"

cd `dirname "$0"`

jmeter="./apache-jmeter-5.5/bin/jmeter"

echo "Remove old results"
rm -rf artipie-upload-res
rm -f artipie-upload.log
mkdir artipie-upload-res

echo "Run jmeter tests"
# -e -o ./artipie-upload-res
"$jmeter" -n -t ./upload-files.jmx -l ./artipie-upload.log -e -o ./artipie-upload-res -Jrepository.host="$host" -Jrepository.port="$port" \
  -Jrepository.path=/chgen/bintest/ -Jduration="$duration"
mv -f artipie-upload.log artipie-upload-res
mv -f artipie-upload-res "files_ul_${host}_${port}_${duration}_$(date +%y-%m-%d_%H-%M-%S)"

