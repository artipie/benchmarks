#!/bin/bash
# Run performance tests for Spring Boot server locally
set -eo pipefail
cd "${0%/*}"

echo "Remove old results"
rm -rf spring-upload-res
rm -f spring-upload.log

mkdir spring-upload-res

echo "Run jmeter tests"
"PATH_TO_JMETER" jmeter -n -t ../files/upload-files.jmx -l spring-upload.log -e -o ./spring-upload-res -Jrepository.host=localhost -Jrepository.port=8080
