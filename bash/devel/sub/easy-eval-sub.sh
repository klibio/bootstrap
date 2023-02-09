#!/bin/bash
script_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
(return 0 2>/dev/null) && echo "######### Entering sourced sub script #########" || echo "######### Entering executed sub script #########"

sub_method() {
    #if [[ sourced == 0 ]]; then
    #    echo "################################################"
    #    echo "######### Entering executed sub script #########"
    #    echo "################################################"
    #else
    #    echo "################################################"
    #    echo "######### Entering sourced sub script #########"
    #    echo "################################################"
    #fi

    echo -e "#\n# 0 is"
    echo "# ${0}"
    echo -e "#\n"

    echo -e "#\n# BASH_SOURCE is"
    echo "# ${BASH_SOURCE}"
    echo -e "#\n"

    echo -e "#\n# script_path is"
    echo "# ${script_path}"
    echo -e "#\n"

    # BASH_SOURCE equals the call from the caller script
    # if path is relative, this works
    #echo -e "#\n# absolute script dir is \n#"
    #echo "$( dirname $(readlink -f ${script_path}/${BASH_SOURCE[0]}))"

    #if [[ "$0" = /* ]]; then
    #    echo -e "# Sub script has been called from an absolute path"
    #else
    #    echo -e "# Sub script has been called with a relative path"
    #fi
}

sub_method