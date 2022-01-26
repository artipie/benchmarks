#!/bin/bash
# Run performance upload test for Artipie server locally
set -eo pipefail
cd "${0%/*}"

echo "Remove old results"
rm -rf artipie-upload-res
rm -f artipie-upload.log

mkdir artipie-upload-res

echo "Run jmeter tests"
"PATH_TO_JMETER" jmeter -n -t ../files/upload-files.jmx -l artipie-upload.log -e -o ./artipie-upload-res -Jrepository.host=localhost -Jrepository.port=8080
