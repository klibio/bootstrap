#!/bin/bash

# arg1 is the path of the properties file to read
# arg2 (true/false) defines if an env variable should be replaced in case it already exists
function readProperties {
    if [ -f $1 ]; then
        echo "export env vars from properties file $1"
        readPropertyFile $1 ${2}
    else
        usage
    fi
}

function readPropertyFile {
    filename=$(basename $1)
    localfile="${TEMP}/${filename}"
    cp -f $1 ${localfile}
    # delete comments
    sed -i '/#.*$/d' ${localfile}
    sed -i '/`/d' ${localfile} # remove lines with backtick
    sed -i '/\\/d' ${localfile} # remove lines with backtick
    # delete empty lines
    trimmed_file=$(cat ${localfile} | awk 'NF')
    while IFS='=' read -r key value; do
        # test key if comment and non-zero
        if [[ ! $key = \#* && -n $key ]]; then
            # as a workaround, - are replaced by _ in order to enable loading of properties
            key=$(echo $key | tr '-' '_')
            value=$(echo $value | awk '{$1=$1};1' ) # remove leading blanks
            # as a workaround, bash special chars are escaped
            # value=$(echo $value | printf %q $value)
            if [ $2 == "true" ] || [ -z "$(eval echo \${${key}:-})" ]; then 
                eval ${key}="${value}"
            else 
                eval echo '${key} is already set and is not changed!'
            fi
            if [[ "true" == ${debug:-false} ]]; then
                echo "export ${key}=${value}"
            fi
            export ${key}=${value}
        fi
    done <<< "${trimmed_file}"
    rm ${localfile}
}

readProperties $1 ${2:-false}