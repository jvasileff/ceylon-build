#!/bin/bash

set -euo pipefail

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

# Start from a clean path
export PATH=/usr/local/bin:/usr/bin:/bin

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

# Increase memory for Java 1.7
export JAVA_OPTS="-Xmx2048m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled"
export ANT_OPTS="-Xmx2048m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled"

# Work from the APP_HOME directory
cd "$APP_HOME" > /dev/null

# Build
echo "----------------------------------------"
echo "Environment"
echo "----------------------------------------"
echo "JAVA_OPTS: \"$JAVA_OPTS\""
echo
echo "ANT_OPTS: \"$ANT_OPTS\""
echo
echo "PATH: \"$PATH\""
echo
java -version
echo
ant -version
echo
mvn -version
echo
uname -a
echo
echo "----------------------------------------"
echo "Build"
echo "----------------------------------------"
[ -d ~/.ceylon ] && echo -e "** WARNING ** ~/.ceylon already exists, build may reuse old artifacts\n"

(cd ceylon && ant dist)
(cd ceylon-sdk && ant publish ide-quick)
(cd ceylon/compiler-java && ant test-quick)
(cd ceylon.formatter && ant publish ide-quick)
(cd ceylon-ide-common && ant publish ide-quick)
(cd ceylon.tool.converter.java2ceylon && ant publish ide-quick)
(cd ceylon-ide-eclipse && mvn clean install -DskipTests)
(cd ceylon && ant clean package)

mkdir -p build/artifacts/ceylon
mkdir -p build/artifacts/ceylon-sdk
mkdir -p build/artifacts/ceylon-eclipse-plugin

cp -a ceylon/dist/ceylon*zip build/artifacts/ceylon
cp -a ceylon-sdk/modules build/artifacts/ceylon-sdk
cp -a ceylon-ide-eclipse/site/target/repository build/artifacts/ceylon-eclipse-plugin
