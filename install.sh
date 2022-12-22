#!/bin/bash
set -Eeuo pipefail
scriptDir=$(cd "$(dirname "$0")" && pwd)

cat << EOF

 ##    ## ##      #### ########  ####  ####### 
 ##   ##  ##       ##  ##     ##  ##  ##     ##
 ##  ##   ##       ##  ##     ##  ##  ##     ##
 #####    ##       ##  ########   ##  ##     ##
 ##  ##   ##       ##  ##     ##  ##  ##     ##
 ##   ##  ##       ##  ##     ##  ##  ##     ##
 ##    ## ####### #### ########  ####  ####### 

  ######  ######## ######## ##     ## ######## 
 ##    ## ##          ##    ##     ## ##     ##
 ##       ##          ##    ##     ## ##     ##
  ######  ######      ##    ##     ## ######## 
       ## ##          ##    ##     ## ##       
 ##    ## ##          ##    ##     ## ##       
  ######  ########    ##     #######  ##       

EOF

function dlFileFromGithub() {
    targetFolder=${2:-~}
    pushd $targetFolder > /dev/null
    curl -sSL \
        https://raw.githubusercontent.com/klibio/bootstrap/main/bash/$os/$1 \
        > $1
    popd > /dev/null
}

function dlAndExtractFileFromGithub() {
    targetFolder=${2:-~}
    curl -sSL \
        https://raw.githubusercontent.com/klibio/bootstrap/main/klibio.tar.gz \
        | tar xvz -C $targetFolder
}


function askUser() {
    file=$1
    targetFolder=${2:-~}
    if [[ $file == *.tar.gz ]]; then
        filename=$(basename -- "$1")
        dirname="${filename%.*}"
        if [ -d $dirname ]; then
            while true; do
                read -p "Do you wish to overwrite $targetFolder/$dirname? " yn
                case $yn in
                    [Yy]* ) dlAndExtractFileFromGithub $file; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        else
            dlAndExtractFileFromGithub $file
        fi
    else
        file=$targetFolder/$1
        if [ -f $file ]; then 
            while true; do
                read -p "Do you wish to overwrite $file? " yn
                case $yn in
                    [Yy]* ) dlFileFromGithub $file; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        else 
            dlFromGithub $file
        fi
    fi
}

askUser .bashrc
askUser .gitconfig
askUser klibio.tar.gz

source ~/.klibio/provisionJava.sh

# identify os
# copy os specific folder from bash
# copy folder .klibio into ~
# execute provisionJava.sh

echo "setup script completed"
