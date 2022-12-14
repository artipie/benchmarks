# Artipie performance tests materials

## JMeter notes

Note that JMeter in Ubuntu 22.04 LTS Linux repository is very old and some modules are missing
Note that JMeter may go crazy when recording requests from localhost to localhost. One may need to use external IP or hostname.
JMeter HTTP proxy mode recording could be done with GUI only.
For now using the following version of JMeter:
`https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-5.5.tgz`


## Some load-testing related scripts
Most scripts rely on JMeter 5.5 and were tested inside Linux with native Docker & java installed.

- `jmeterReport.sh` allows to generate report files for given JMeter jmx file.
- `Dockerfile.client` allows to run for recording `conan install` command with given Conan server URL and JMeter proxy URL
- `artipie-docker.sh` run test docker instance of artipie
- `jmx-run.sh` binary data test with generated random data of small/medium/laarge files
- `jmx-local.sh` run local artipie + binary test (above), then stop artipie
- `jmx-files-maven-ul.sh` upload maven artifacts test set to files repository adapter (bintest repo)
- `jmx-files-maven-dl.sh` download maven artifacts test set to files repository adapter (bintest repo)
- `jmx-maven-ul.s` upload maven artifacts test set to maven repo (maventest repo)
- `jmx-maven-dl.s` download maven artifacts test set from maven repo (maventest repo)
- `jmx-files-ul.sh` upload random binary data files, like `jmx-run.sh`
- `jmx-files-ul.sh` download files by list, generated for upload script above
- `maven-repo-reset.sh` reset & wipe data for maven repository via Artipie REST API, for tests

## Downloading maven artifacts via proxy (JMeter)
```
time mvn clean install -Dhttp.proxyHost=localhost -Dhttp.proxyPort=8888 -Dhttps.proxyHost=localhost -Dhttps.proxyPort=8888 -Dmaven.wagon.http.ssl.insecure=true -Dmaven.test.skip -Ddockerfile.skip=true
```
