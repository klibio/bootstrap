#!/bin/bash
#
# proof-of-performance
#
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

echo "# DEBUG START"

echo "## DEBUG environment variables"
env | sort 

echo "## DEBUG directories/files - only relevant are displayed"
ls -la ~/.bashrc

echo "### content of ~/.bashrc - start"
cat ~/.bashrc
echo "### content of ~/.bashrc - end"

ls -la ~/.klibio/*

###########################################################
# HINT aliases are loaded by following command
# so some commands like e.g. ls or cat might not work
###########################################################
echo "### source .bashrc"
. ~/.bashrc

echo "## DEBUG alias - start"
alias -p
echo "## DEBUG alias - end"

#echo "## DEBUG functions - start"
#declare -F
#echo "## DEBUG functions - end"

echo "## DEBUG PATH"
echo $PATH

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
    set-java.sh $javaVersion
    test_env_var JAVA_HOME
    java -version
    set -u
}

echo "# test java version"
testJava  8
testJava 11
testJava 17
