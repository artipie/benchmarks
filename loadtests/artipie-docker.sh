#!/bin/bash -e

if [ $# -ne 1 ]; then 
    echo "Usage: $0 port" && exit 1
fi
port="$1"
JMX_PORT=9999
JDEBUG=8000
JMX_AGENT=12345
cd `dirname "$0"`

docker stop artipie || :
docker run --pull=missing -d --rm --name artipie -it -v "$PWD/root/etc:/etc" -v "$PWD/root/var:/var/artipie"  --user 0:0 -p "$port":8080 -p 8086:8086 -p $JMX_AGENT:$JMX_AGENT -p $JMX_PORT:$JMX_PORT -p$JDEBUG:$JDEBUG -e JVM_ARGS="-javaagent:/etc/jmx_prometheus_javaagent-0.17.2.jar=$JMX_AGENT:/etc/config-agent.yaml -agentlib:jdwp=transport=dt_socket,server=y,address=*:$JDEBUG,suspend=n -Djava.rmi.server.hostname=localhost -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=$JMX_PORT -Dcom.sun.management.jmxremote.rmi.port=$JMX_PORT -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false" chgena/artipie:bc37982.1
