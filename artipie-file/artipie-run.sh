#!/bin/bash
# Start Artipie server
set -eo pipefail

mvn clean install
mvn dependency:copy-dependencies
java -cp "target/artipie-file-1.0-SNAPSHOT.jar:target/classes/*:target/dependency/*" com.artipie.file.Application
