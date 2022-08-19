# Artipie performance tests materials

# JMeter notes

Note that JMeter in Ubuntu 22.04 LTS Linux repository is very old and some modules are missing
Note that JMeter may go crazy when recording requests from localhost to localhost. One may need to use external IP.
JMeter HTTP proxy mode recording could be done with GUI only.
For now using the following version of JMeter:
`https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-5.5.tgz`


# Some scripts (WIP)

 - `jmeterReport.sh` allows to generate report files for given JMeter jmx file.
 - `Dockerfile.client` allows to run for recording `conan install` command with given Conan server URL and JMeter proxy URL

