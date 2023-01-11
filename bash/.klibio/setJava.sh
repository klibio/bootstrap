#!/bin/bash
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

KLIBIO=${KLIBIO:=`echo $HOME/.klibio`}
export KLIBIO=${KLIBIO}
java_home_suffix=${java_home_suffix:=}

. ${KLIBIO}/env.sh

. $KLIBIO/env.sh

#env variables can be changed only if we call the script with `source setJava.sh`

removeFromPath () {
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
        export JAVA_HOME=${KLIBIO}/java/ee/JAVA8${java_home_suffix}
    ;;
    11)
        export JAVA_HOME=${KLIBIO}/java/ee/JAVA11${java_home_suffix}
    ;;
    17)
        export JAVA_HOME=${KLIBIO}/java/ee/JAVA17${java_home_suffix}
    ;;
    *)
        echo "usage error: setJava <version>\n version can be one of unset, 8, 11, 17"
        exit 1
    ;;
esac

echo JAVA_HOME=${JAVA_HOME}
export PATH=${JAVA_HOME}/bin:$PATH

java -version

# restore default behaviour
set +o errexit  # exit if any statement returns a non-true return value
set +o pipefail # exit if any pipe command is failing
