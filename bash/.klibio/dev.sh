#!/bin/bash

# activate bash checks
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

echo "# DEVELOPMENT start"

unset ospath

removeFromPath () {
    local segment=$1
    if [[ $ospath == *"\\"* ]]; then
        # windows remove segment path (and optional trailing semi-colon)
        export PATH=$(echo ${PATH} | sed -E -e "s/${segment/\\/\\\\};?//" -e "s/;$//")
    else
        # *nix remove segment from path (and optional trailing colon)
        export PATH=$(echo ${PATH} | sed -E -e "s;${segment}:?;;" -e "s;:$;;")
    fi
    export $PATH
}

PATH=$PATH:"/c/dir_a:/c/dir_b:/c/dir_c:/c/dir_d"
echo "PATH=${PATH}"

path2remove="/c/dir_a"
echo "path after removing ${path2remove} from path $( removeFromPath ${path2remove} )"

path2remove="/c/dir_b"
echo "path after removing ${path2remove} from path $( removeFromPath ${path2remove} )"

path2remove="/c/dir_d"
echo "path after removing ${path2remove} from path $( removeFromPath ${path2remove} )"


ospath="c:\dir_a;c:\dir_b;c:\dir_c;c:\dir_d"
echo "ospath=${ospath}"

path2remove="c:\dir_a"
echo "path after removing ${path2remove} from path $( removeFromPath ${path2remove} )"

path2remove="c:\dir_b"
echo "path after removing ${path2remove} from path $( removeFromPath ${path2remove} )"

path2remove="c:\dir_d"
echo "path after removing ${path2remove} from path $( removeFromPath ${path2remove} )"

echo "# DEVELOPMENT finish"

