#!/bin/bash

script_path=$( dirname $(readlink -f $0 ) &> /dev/null && pwd )

main2() {
    # BASH_SOURCE equals the call from the caller script
    # if path is relative, this works
    echo "$( dirname $(readlink -f ${script_path}/${BASH_SOURCE}))"

}