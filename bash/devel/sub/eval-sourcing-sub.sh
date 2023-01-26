#!/bin/bash
script_path="$(dirname $(readlink -f $0))"
echo script_path=${script_path}

main2() {
    echo -e "\n#\n# path evaluation start # $BASH_SOURCE\n#\n"
    echo "\$0=$0"
    echo "\$#=$#"
    echo "\$@=$@"
    echo "\$?=$?"

    local absolute_script_path=$(readlink -f $0)
    echo absolute_script_path=${absolute_script_path}

    local absolute_script_dir=$(dirname $(readlink -f $0))
    echo absolute_script_dir=${absolute_script_dir}

    local filename=$(echo $0 | sed "s/.*\///")
    echo filename=${filename}

    echo BASH_SOURCE=$BASH_SOURCE

    local absolute_BASH_SOURCE=$(readlink -f $BASH_SOURCE)
    echo absolute_BASH_SOURCE=${absolute_BASH_SOURCE}

    local filename_BASH_SOURCE=$(echo $BASH_SOURCE | sed "s/.*\///")
    echo filename_BASH_SOURCE=${filename_BASH_SOURCE}

    local absolute_BASH_SOURCE_dir=$(dirname $(readlink -f $BASH_SOURCE))
    echo absolute_BASH_SOURCE_dir=${absolute_BASH_SOURCE_dir}
}

main2
