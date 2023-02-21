#!/bin/bash -ex
# Basic localhost JMeter + Conan test
# remote: http://localhost:9300
# proxy: http://localhost:8888

conan remote add -f localtest "$1" False
http_proxy="$2" conan install -r localtest .

