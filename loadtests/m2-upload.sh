#!/bin/bash -e
if [ $# -ne 2 ]; then 
    echo "Usage: $0 path/to/.m2 repo_url" && exit 1
fi
#cd `dirname "$0"`
url="$2"
m2xml=`readlink -f ./m2-proxy.xml`
if [ ! -d "$1/repository" ] ; then
    echo "./m2/repository is missing" && exit 2
fi
cd "$1/repository"
pwd
#/mnt/vmdata1/bin/maven-mvnd/bin/mvnd.sh
#find . -type f \( -name "*.jar" -o -name "*.sha1" -o -name "*.pom" \) -exec curl -v -T {} "$url/{}" \;
rm -fv mlog.log
find . -type f -name "*.jar"|xargs -d'\n' -n1 bash -c '
echo $0 $1;
pomFile="${1%.jar}.pom";
pomArg="";
if [ -f "$pomFile" ] ; then pomArg="-DpomFile=$pomFile" ; else echo "NO POM!"; pomFile=""; fi;
/mnt/vmdata1/bin/maven-mvnd/bin/mvnd.sh -V -s /mnt/vmdata1/w/local/artipie/benchmarks/loadtests/m2-proxy.xml deploy:deploy-file -Dmaven.wagon.http.ssl.insecure=true  -Durl="$0" -Dfile="$1" $pomArg;
r=$?; if [[ "$r" -ne 0 || -z "$pomFile" ]] ; then echo "File: $1; pom: $pomFile; r: $r" >> mlog.log; fi;
echo "===================================="
' "$url"
