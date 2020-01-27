#!/bin/bash

# Determine APP_HOME directory (the parent of this file)
PRG="$0"
while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`"/$link"
    fi
done
SAVED="`pwd`"
cd "`dirname \"$PRG\"`" > /dev/null
APP_HOME="`pwd -P`"
cd "$SAVED" > /dev/null

# temp dir, resolving symlinks
OUTPUT_DIR=$(cd $(mktemp -d -t ceylon-build) ; pwd -P)

docker run --rm \
    -v "$APP_HOME":/project:ro \
    -v "$OUTPUT_DIR":/output:rw \
    adoptopenjdk:8u232-b09-jdk-hotspot-bionic \
    /bin/bash -c "
        apt-get update &&
        apt-get install -y git &&
        git clone -s /project clone &&
        cd clone &&
        git submodule update --init --force --recursive --depth=50 &&
        ./build.sh &&
        cp -a artifacts /output"

echo "** Build artifacts (if any) copied to $OUTPUT_DIR"

