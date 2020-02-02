#!/bin/bash

set -euo pipefail

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

# Work from the APP_HOME directory
cd "$APP_HOME" > /dev/null

# Run build.sh
mkdir -p build
time ./build.sh 2>&1 | tee "build/log-$(date "+%Y-%m-%dT%H%M%S").txt"
