#!/bin/sh

set -eu

# Determine APP_HOME directory
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

# Setup environment
. "$APP_HOME/env.sh"

# Create temp output dir, resolving symlinks
OUTPUT_DIR=`mktemp -d -t ceylon-build`
SAVED="`pwd`"
cd "$OUTPUT_DIR" > /dev/null
OUTPUT_DIR="`pwd -P`"
cd "$SAVED" > /dev/null

echo "building Docker image"

# adoptopenjdk:8u232-b09-jdk-hotspot-bionic \
# openjdk:7u221-jessie

BASE_IMAGE=`docker build -q - << EOF
FROM openjdk:7u221-jessie

RUN apt-get update &&\
    apt-get install -y git &&\
    rm -rf /var/lib/apt/lists/*
EOF
`

echo "running Docker image $BASE_IMAGE\n"

docker run --rm -t -i \
    -v "$APP_HOME":/project:ro \
    -v "$OUTPUT_DIR":/output:rw \
    $BASE_IMAGE \
    /bin/sh -c "
        set -eux
        cp -a /project work
        cd work
        git clean -fxd
        git submodule foreach git clean -fxd
        ./build.sh
        cp -a artifacts /output"

echo "\nbuild artifacts (if any) copied to $OUTPUT_DIR"

