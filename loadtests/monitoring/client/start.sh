#!/bin/bash
if [ $# -ne 3 ]; then
    echo "Usage: $0 telegraf_hostname username password" && exit 1
fi
docker-compose down || :
docker-compose rm -s -f
rm -fv conf/prometheus.yml 
cp -fv conf/prometheus.yml.base conf/prometheus.yml
echo -e "\n  - url: \"http://$1:1234/receive\" #telegraf"| tee -a conf/prometheus.yml
echo -e "    basic_auth:"| tee -a conf/prometheus.yml
echo -e "      username: $2"| tee -a conf/prometheus.yml
echo -e "      password: $3"| tee -a conf/prometheus.yml
ARTIPIE_USER="$(id -u):$(id -g)" docker-compose up --abort-on-container-exit
