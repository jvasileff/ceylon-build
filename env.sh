#!/bin/sh

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

