#!/bin/bash

# ISSUES
#
# - If PATH contains anything that might lead to plugin discovery in
#   PathPlugins (which includes other versions of Ceylon) the build will
#   attempt to generate docs for those plugins! When building 1.3.4-SNAPSHOT,
#   `ant package` fails attempting to create docs for ceylon.formatter/1.3.3 if
#   Ceylon 1.3.3 is in the path.
#
# - ~/.ceylon is used for the build, and should be removed prior to each clean
#   build.
#
# - Directories named .ceylon contained within any ancestor directories may
#   affect the build... and therefore should not exist.

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

fail() {
  echo "error: $@"
  exit 1
}

# Work from the APP_HOME directory
cd "$APP_HOME" > /dev/null

# Start from a clean path
export PATH=/bin:/usr/bin

# Add Java to path
export PATH="$JAVA_HOME/bin:$PATH"

# Setup Maven environment
export MAVEN_HOME="$APP_HOME/apache-maven"
export PATH="$MAVEN_HOME/bin:$PATH"

# Setup Ant environment
export ANT_HOME="$APP_HOME/apache-ant"
export PATH="$ANT_HOME/bin:$PATH"

# Setup Ceylon environment
export CEYLON_HOME="$APP_HOME/ceylon/dist/dist"
export PATH="$CEYLON_HOME/bin:$PATH"

# Build
(cd ceylon && ant dist) &&
(cd ceylon-sdk && ant publish ide-quick) &&
(cd ceylon.formatter && ant publish ide-quick) &&
(cd ceylon-ide-common && ant publish ide-quick) &&
(cd ceylon.tool.converter.java2ceylon && ant publish ide-quick) &&
(cd ceylon-ide-eclipse && mvn clean install -DskipTests) &&
(cd ceylon && ant clean package) &&
mkdir artifacts &&
mkdir artifacts/ceylon &&
mkdir artifacts/ceylon-sdk &&
mkdir artifacts/ceylon-eclipse-plugin &&
cp -a ceylon/dist/ceylon*zip artifacts/ceylon &&
cp -a ceylon-sdk/modules artifacts/ceylon-sdk &&
cp -a ceylon-ide-eclipse/site/target/repository artifacts/ceylon-eclipse-plugin

