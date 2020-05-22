#!/bin/sh
if [ $# -lt 4 ]
then
  echo >&2 "Usage: ./entry-point.sh <adapter> <jmeter-scenario-file> (artipie|sonatype) <version>"
  exit 1
fi

/bin/sh $(dirname "$0")/$1/run.sh $2 $3 $4
cp -fr $(dirname "$0")/$1/report $GITHUB_WORKSPACE
