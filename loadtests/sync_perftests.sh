#!/bin/bash -ex
if [ $# -lt 1 ]; then 
    echo "Usage: $0 URL [login password]" && exit 1
fi

# perftests_repo/perftests/<tag>/<testname>/statistics.json
# perftests_repo/jfr/artipie.last.jfr.tar.xz
# perftests_repo/graphs/<testname>.png

cd `dirname "$0"`

curlExtra=""
if [ -n "$2" ] && [ -n "$3" ] ; then
    curlExtra="-u${2}:${3}"
fi

repoName='perftests_repo'
repoPath="./$repoName"
repoUrl="$1/$repoName"
testsList="tests.txt"

mkdir -p "$repoPath"
pushd "$repoPath"


curl -f -s -S $curlExtra "$repoUrl/$testsList" -o "$testsList"

cat  "$testsList"|while read a ; do
  read b || :; read c || :; read d || :
  for test in $a $b $c $d ; do
    if [ -s "$test" ] ; then
        echo "test result exist: $test"
    else  
        mkdir -p $(dirname "$test")
        curl -f -v $curlExtra "$repoUrl/$test" -o "$test" &
    fi
  done
  wait
done

find "perftests" -name statistics.json > "$testsList"

cat  "$testsList"|while read a ; do
  read b || :; read c || :; read d || :
  for test in $a $b $c $d ; do
    curl -f -v -X PUT -T "$test" $curlExtra "$repoUrl/$test" &
  done
  wait
done

curl -f -s -S -X PUT -T "$testsList" $curlExtra "$repoUrl/$testsList"
popd
