#!/bin/bash -li

# activate bash checks
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

echo "# DEBUG START"

echo "## DEBUG environment variables"
env | sort 

echo "## DEBUG directories/files - only relevant are displayed"
ls -la ~/.bashrc
echo "### content of ~/.bashrc"
cat ~/.bashrc

# must be used before sourcing .bashrc (cause ls will become an alias)
ls -la ~/.klibio/*
ls -la ~/.klibio/*/*

echo "### source .bashrc"
. $HOME/.bashrc

echo "## DEBUG alias"
alias -p

echo "# DEBUG END"

# test for variable existence and output value if found
test_env_var() {
    set +u
    declare var=$1
    echo -ne "checking for $var ... "
    if [ -n "${!var}" ]; then
        echo "found var $var=${!var}"
    else
        echo "missing variable $var" && exit 1
    fi
    set -u
}

echo "# test variable existences"
test_env_var KLIBIO

testJava() {
    set +u
    declare javaVersion=$1
    echo "## testing java $javaVersion"
    source ${KLIBIO}/setJava.sh $javaVersion
    test_env_var JAVA_HOME
    java -version
    set -u
}

echo "# test java version"
testJava 8
testJava 11
testJava 17
