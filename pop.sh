#!/bin/bash
set -Eeuo pipefail

GITHUB_REF_NAME=${1:-main}

echo "# INSTALL"
./install.sh -o -b=$GITHUB_REF_NAME

echo "# DEBUG START"
env | sort && ls -lar
echo "# DEBUG START"

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

echo "# test variable existences"

testEnvVar KLIBIO
testEnvVar JAVA_HOME
