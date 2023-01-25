#!/bin/bash
#
# switch the java versions
#
script_dir=$(dirname $(readlink -e $BASH_SOURCE))
# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi

# load library
. ${script_dir}/klibio.sh
java_home_suffix=${java_home_suffix:=}

removeFromPath () {
    local segment=$1
    # *nix remove segment from path (and optional trailing colon)
    export PATH=$(echo ${PATH} | sed -E -e "s;${segment}:?;;" -e "s;:$;;")
}

if [ -n "${JAVA_HOME+x}" ]; then  
    removeFromPath $JAVA_HOME  
fi

case ${1:-"x"} in
    unset)
        removeFromPath $JAVA_HOME
        unset JAVA_HOME
        echo "available Java LTS are 8, 11, 17"
        exit 0
    ;;
    8)
        removeFromPath $JAVA_HOME
        JAVA_HOME=${KLIBIO}/java/ee/JAVA8${java_home_suffix}
    ;;
    11)
        removeFromPath $JAVA_HOME
        JAVA_HOME=${KLIBIO}/java/ee/JAVA11${java_home_suffix}
    ;;
    17)
        removeFromPath $JAVA_HOME
        JAVA_HOME=${KLIBIO}/java/ee/JAVA17${java_home_suffix}
    ;;
    *)
        echo -e "usage error: set-java <version>\n version can be one of <unset, 8, 11, 17>"
        exit 1
    ;;
esac

echo "configure JAVA_HOME=${JAVA_HOME}"
export JAVA_HOME=${JAVA_HOME}
export PATH=${JAVA_HOME}/bin:$PATH

java -version

# reset the bash settings
set +o nounset  # exit with error on unset variables
set +o errexit  # exit if any statement returns a non-true return value
set +o pipefail # exit if any pipe command is failing
