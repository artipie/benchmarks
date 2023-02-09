#!/bin/bash -e

# Generate maven repo in `upload-maven-src` for artifacts list in `upload-maven.csv`.
# SimpleHTTPPutServer.py is used to save new artifact files from maven deploy-file.

baseDir="$PWD/$(dirname $0)"
srcRepo="https://repo1.maven.org/maven2"
srcList="$baseDir/upload-maven.csv"
dstDir="$baseDir/upload-maven-src/repository"
tmpRepo="$(mktemp -d)"
pythonServer="$baseDir/SimpleHTTPPutServer.py"
pyPort=9998

if [ -z "$(which wget)" ] ; then
  echo "Error. wget is required." && exit 1
fi
if [ -z "$(which mvn)" ] ; then
  echo "Error. mvn is required." && exit 2
fi
if [ -z "$(which python3)" ] ; then
  echo "Error. python3 is required." && exit 3
fi

rm -rf "$dstDir"
mkdir -p "$dstDir"
pushd "$dstDir"
python3 "$pythonServer" "$pyPort" &
srvPid=$!
popd
sleep 1
if [ ! -d "/proc/$srvPid" ] ; then
  echo "Failed to start server on port $pyPort!" && exit 4
fi
kill "$srvPid"

echo "wget..."

mkdir -p "$tmpRepo/repository"

i=0
for f in $(cat $srcList) ; do
  wget "$srcRepo/$f" -P "$tmpRepo/repository/$(dirname $f)"
done

echo "Creating repo with metadata..."

rm -rf "$dstDir"
mkdir -p "$dstDir"
pushd "$dstDir"
python3 "$pythonServer" "$pyPort" &
srvPid=$!
popd
sleep 1
if [ -d "/proc/$srvPid" ] ; then
  echo "Server started on port $pyPort with PID $srvPid; data from $tmpRepo to $dstDir"
  ./m2-upload.sh "$tmpRepo" "http://localhost:$pyPort" 2>/dev/null
else
  echo "Failed to start server on port $pyPort!"
fi
kill "$srvPid"
rm -rf "$tmpRepo"

