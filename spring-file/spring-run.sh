#!/bin/sh
# Start Spring Boot server

mvn clean install
mvn dependency:copy-dependencies
rm rf spring.log
java -cp "target/spring-file-1.0-SNAPSHOT.jar:target/classes/*:target/dependency/*" com.artipie.spring.Application