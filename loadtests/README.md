# Artipie performance tests materials

Tests were performed in Linux, Ubuntu 22.04 LTS x86_64, with local docker & openjdk installed from Ubuntu repository. Technically, WSL2/Windows 11 hypervisor was used for local runs.

## JMeter notes

Note that JMeter in Ubuntu 22.04 LTS Linux repository is very old and some modules are missing.
Note that JMeter may go crazy when recording requests from localhost to localhost. One may need to use external IP or hostname.
JMeter HTTP proxy mode recording could be done with GUI only.
For now using the following version of Apache JMeter:
`https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-5.5.tgz`

## JFR and debugging support

JFR recording for running artipie docker container could be accomplised via remote JMX connections. Both, `artipie-docker.sh` and `monitoring/client` open port `9999` for JMX connections to artipie container. Java debugger could be attached via 8000 port.
JMX connections for JFR recording were tested with `JDK Mission Control v8.2.1` for Linux and Windows (native docker inside WSL2).

## Some load-testing related scripts
Most scripts rely on JMeter 5.5 and were tested inside Linux with native Docker & java installed.

- `jmeterReport.sh` allows to generate report files for given JMeter jmx file.
- `Dockerfile.client` allows to run for recording `conan install` command with given Conan server URL and JMeter proxy URL
- `artipie-docker.sh` run test docker instance of artipie
- `jmx-run.sh` binary data test with generated random data of small/medium/laarge files
- `jmx-local.sh` run local artipie + binary test (above), then stop artipie
- `jmx-files-maven-ul.sh` upload maven artifacts test set to the files repository adapter (bintest repo)
- `jmx-files-maven-dl.sh` download maven artifacts test set to the files repository adapter (bintest repo)
- `jmx-maven-ul.s` upload maven artifacts test set to the maven repo (maventest repo)
- `jmx-maven-dl.s` download maven artifacts test set from the maven repo (maventest repo)
- `jmx-files-ul.sh` upload random binary data files, like `jmx-run.sh`
- `jmx-files-dl.sh` download files by list, generated for upload script above
- `maven-repo-reset.sh` reset & wipe data for maven repository via Artipie REST API, for tests
- `bintest-repo-reset.sh` reset & wipe data for binary files repository via Artipie REST API, for tests
- `monitoring/*` monitoring support for artipie, which consist of two parts, see `README.md` there.

## How to run tests locally
1. Setup Ubuntu 22.04 environment with dependencies: `sudo apt install curl openjdk-17-jdk docker.io`
2. Ensure docker runs correctly: `docker run hello-world`. Also check java: `java -version`.
3. Put Apache JMeter v5.5 (link above) to  `loadtests/apache-jmeter-5.5` directory (or symlink to it).
4. Run artipie testing instance: `./artipie-docker.sh 8081`
5. Run some test script from above for 30 seconds: `./jmx-run.sh localhost 8081 30`
6. Check html report in test results directory: `test_*/index.html`
7. Do extra test and compare json output for two test results: `test_*/statistics.json`
8. Stop artipie testing instance: `docker stop artipie`

## Downloading maven artifacts via JMeter proxy
1. Run Apache JMeter in GUI mode
2. Open project, and add new element: `Edit->Add->Non-test elements->HTTPS test script recorder`
3. For this element, set `Global settings->Port` to `8888` and press Start.
4. Use command below to download artifacts via this proxy:
```
time mvn clean install -Dhttp.proxyHost=localhost -Dhttp.proxyPort=8888 -Dhttps.proxyHost=localhost -Dhttps.proxyPort=8888 -Dmaven.wagon.http.ssl.insecure=true -Dmaven.test.skip -Ddockerfile.skip=true
```
