#!/bin/bash
#
#
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-.}" )" &> /dev/null && pwd )

# test for variable existence and output value if found
test_env_var_existence() {
    declare envvar_name=$1
    if [[ ! -v ${envvar_name} ]]; then
        echo "env var is not set"
    elif [[ -z "${envvar_name}" ]]; then
        echo "env var is set to the empty string"
    else
        echo "env var ${envvar_name}=${!envvar_name}"
    fi

#    echo -ne "checking env variable for $envvar_name ... "
#    if [ -n "${!envvar_name}" ]; then
#        echo "found env var $envvar_name=${!envvar_name}"
#    else
#        echo "missing prop $envvar_name" && exit 1
#    fi
}

test_env_var() {
    declare envvar_name="$1"
    declare value="$2"
    test_env_var_existence "${envvar_name}"
    if [[ ${value} == ${!envvar_name} ]]; then
        echo "found env var ${envvar_name}=${!envvar_name}"
    else
        echo "env <${envvar_name}>=<${!value}> is not expected value <$value>" && exit 1
    fi
}

. ${script_dir}/../.klibio/prop2env.sh ${script_dir}/testdata/java_env.properties

test_env_var_existence td_key_empty
test_env_var td_key_value td_value_string
