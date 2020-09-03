#!/usr/bin/env bash

# Enter script located dir, whaterver the script is called from
cd "$( dirname "${BASH_SOURCE[0]}" )"

if [ -z ${TF_VAR_secret_key+x} ]; then echo "TF_VAR_secret_key is unset"; exit 1; else echo "TF_VAR_secret_key is set to '$TF_VAR_secret_key'"; fi
if [ -z ${TF_VAR_access_key+x} ]; then echo "TF_VAR_access_key is unset"; exit 1; else echo "TF_VAR_access_key is set to '$TF_VAR_access_key'"; fi

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Usage: specific-versions.sh <list of artipie versions>"
    echo "Example: ./specific-versions.sh 0.9.5 0.9.3 0.9.2 0.9.1"
    exit 1
fi

set -x
set -e
versions=( "$@" )
for version in "${versions[@]}"
do
	echo "Running benchmarks for version $version"
    ARTIPIE_VERSION=$version ./entry-point.py
    mv benchmark-results.json benchmark-results-$version.json 
done