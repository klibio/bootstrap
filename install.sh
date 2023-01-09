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
    file=$(basename -- "$1")
    targetFolder=${2:-~}
    url=https://raw.githubusercontent.com/klibio/bootstrap/main/bash/$os/$file
    pushd $targetFolder > /dev/null
    echo "downloading $url"
    curl -sSL \
        $url \
        > $file
    popd > /dev/null
}

function dlAndExtractFileFromGithub() {
    targetFolder=${2:-~}
    url=https://raw.githubusercontent.com/klibio/bootstrap/main/$1
    echo "downloading and extract $url"
    curl -sSL \
        $url \
        | tar xvz -C $targetFolder > /dev/null
}

function askUser() {
    file=$1
    targetFolder=${2:-~}
    if [[ $file == *.tar.gz ]]; then
        dirname="${file%.*.*}"
        if [ -d "$targetFolder/$dirname" ]; then
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
        file=$targetFolder/$file
        if [ -f $file ]; then 
            while true; do
                read -p "Do you wish to overwrite $file? " yn
                case $yn in
                    [Yy]* ) dlFileFromGithub $file; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer [y]es or [n]o.";;
                esac
            done
        else 
            dlFileFromGithub $file
        fi
    fi
}

askUser .klibio.tar.gz
source ~/.klibio/env.sh

askUser .bashrc
askUser .gitconfig

source ~/.klibio/provisionJava.sh

# identify os
# copy os specific folder from bash
# copy folder .klibio into ~
# execute provisionJava.sh

echo "setup script completed"
