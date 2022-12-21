#!/bin/bash

#env variables can be changed only if we call the script with `source setJava.sh`

function removeFromPath () {
    export PATH=$(echo $PATH | sed -E -e "s;:$1;;" -e "s;$1:?;;")
}

if [ -n "${JAVA_HOME+x}" ]; then  
    removeFromPath $JAVA_HOME  
fi

oracleJava="/c/Program Files (x86)/Common Files/Oracle/Java/javapath"

case $1 in
    unset)
        removeFromPath $oracleJava
        export JAVA_HOME=
        echo "JAVA_HOME unset - available Java are 8, 11, 11-5, pai11"
    ;;
    8)
        export JAVA_HOME=$KLIBIO/java/ee/JAVA8
    ;;
    11)
        export JAVA_HOME=$KLIBIO/java/ee/JAVA11
    ;;
    17)
        export JAVA_HOME=$KLIBIO/java/ee/JAVA17
    ;;
    *)
        echo "usage error: setJava <version>\n version can be one of unset, 8, 11, 17"
    ;;
esac

echo JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH;
java -version
