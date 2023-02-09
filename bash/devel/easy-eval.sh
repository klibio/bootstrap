#!/bin/bash
script_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "###############################################"
echo "############# Entering main script #############"
echo "###############################################"

echo -e "#\n# 0 is"
echo "# ${0}"
echo -e "#\n"

echo -e "#\n# BASH_SOURCE is"
echo "# ${BASH_SOURCE}"
echo -e "#\n"

echo -e "#\n# script path is"
echo "# ${script_path}"
echo -e "#\n"

relativeCall() {
    ${script_path}/sub/easy-eval-sub.sh
}


sourceScript() {
    . ${script_path}/sub/easy-eval-sub.sh
}

relativeCall
sourceScript
