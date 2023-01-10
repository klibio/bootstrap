#!/bin/bash
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
curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install.sh > ./klibio_setup.sh
chmod u+x ./klibio_setup.sh
# for argument passing see https://unix.stackexchange.com/a/144519/116365
bash -x ./klibio_setup.sh -b=${branch} -o
rm klibio_setup.sh

echo "# source the installed .bashrc file "
source "$HOME"/.bashrc

echo "# DEBUG START"
env | sort && ls -lar
echo "# DEBUG START"

echo "# test variable existences"

testEnvVar KLIBIO
testEnvVar JAVA_HOME
