#!/bin/sh
# Run performance tests for Spring Boot server locally

echo "Remove old results"
rm -rf spring-upload-res
rm spring-upload.log

mkdir -p spring-upload-res

echo "Run jmeter tests"
"PATH_TO_JMETER" jmeter -n -t ../files/upload-files.jmx -l spring-upload.log -e -o ./spring-upload-res -Jrepository.host=localhost -Jrepository.port=8080
sleep 10
