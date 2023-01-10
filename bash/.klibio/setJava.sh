#!/bin/bash
set -x          # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing
export KLIBIO=${KLIBIO:=`echo $HOME/.klibio`}

#env variables can be changed only if we call the script with `source setJava.sh`

function removeFromPath () {
    export PATH=$(echo $PATH | sed -E -e "s;:$1;;" -e "s;$1:?;;")
}

if [ -n "${JAVA_HOME+x}" ]; then  
    removeFromPath $JAVA_HOME  
fi

case $1 in
    unset)
        unset JAVA_HOME
        echo "JAVA_HOME unset - available Java LTS are 8, 11, 17"
        exit 0
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
        exit 1
    ;;
esac

echo JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH
java -version
