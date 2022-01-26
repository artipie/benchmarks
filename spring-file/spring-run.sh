#!/bin/bash
# Start Spring Boot server
set -eo pipefail

mvn clean install
mvn dependency:copy-dependencies
java -cp "target/spring-file-1.0-SNAPSHOT.jar:target/classes/*:target/dependency/*" com.artipie.spring.Application
