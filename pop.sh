#!/bin/bash
set -x
set -Eeuo pipefail

branch=${1:-main}

function testEnvVar() {
    set +u
    declare var=$1
    if [ -n "${!var}" ]; then
        echo "found var $var=${!var}"
    else
        echo "missing variable $var" && exit 1
    fi
    set -u
}

echo "# INSTALL"
# for argument passing see https://unix.stackexchange.com/a/144519/116365
/bin/bash -c '$(curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/'${branch}'/install.sh) "$@"' bash -b=${branch}

echo "# source the installed .bashrc file "
source "$HOME"/.bashrc

echo "# DEBUG START"
env | sort && ls -lar
echo "# DEBUG START"

echo "# test variable existences"

testEnvVar KLIBIO
testEnvVar JAVA_HOME
