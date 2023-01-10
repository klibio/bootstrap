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
bash ./klibio_setup.sh -b=${branch} -o
rm klibio_setup.sh

echo "# DEBUG START"

echo "## environment variables"
env | sort 

echo "## directories/files"
ls -la ~/.klibio/*/*

echo "## alias"
alias

echo "# DEBUG END"

echo "# source the installed .bashrc file "
source "$HOME"/.bashrc

echo "# test variable existences"
testEnvVar KLIBIO

setJava 8
testEnvVar JAVA_HOME
java -version

setJava 11
testEnvVar JAVA_HOME
java -version

setJava 17
testEnvVar JAVA_HOME
java -version

setJava unset
testEnvVar JAVA_HOME
