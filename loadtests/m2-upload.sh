#!/bin/bash -e
if [ $# -ne 2 ]; then 
    echo "Usage: $0 path/to/.m2 repo_url" && exit 1
fi
#cd `dirname "$0"`
url="$2"
m2xml=`readlink -f ./m2-proxy.xml`
if [ ! -d "$1/repository" ] ; then
    echo "./$1/repository .m2 repo is missing" && exit 2
fi
cd "$1/repository"
pwd
# /home/evgeny/bin/maven-mvnd-0.8.2-linux-amd64/bin/mvnd.sh
# -s /home/evgeny/w/artipie/benchmarks/loadtests/m2-local.xml
#find . -type f \( -name "*.jar" -o -name "*.sha1" -o -name "*.pom" \) -exec curl -v -T {} "$url/{}" \;
rm -fv mlog.log
find . -type f -name "*.jar"|xargs -d'\n' -n1 bash -c '
echo $0 ${1}:;
pomFile="${1%.jar}.pom";
pomArg="";
if [ -f "$pomFile" ] ; then pomArg="-DpomFile=$pomFile" ; else echo "NO POM!"; pomFile=""; fi;
mvn -V deploy:deploy-file -Dmaven.wagon.http.ssl.insecure=true  -Durl="$0" -Dfile="$1" $pomArg;
r=$?; if [[ "$r" -ne 0 || -z "$pomFile" ]] ; then echo "File: $1; pom: $pomFile; r: $r" >> mlog.log; fi;
echo "===================================="
' "$url"
