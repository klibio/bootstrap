#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
branch=main
overwrite=false

for i in "$@"; do
  case $i in
    -o|--overwrite)
      overwrite=true
      shift # past argument=value
      ;;
    -b=*|--branch=*)
      branch="${i#*=}"
      shift # past argument=value
      ;;
    -*|--*)
      echo "Unknow option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

# activate bash checks
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

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

dl_file_from_github() {
    file=$(basename -- "$1")
    targetFolder=${2:-~}
    url=https://raw.githubusercontent.com/klibio/bootstrap/$branch/bash/$os/$file
    pushd $targetFolder > /dev/null
    echo "downloading $url"
    curl -sSL \
        $url \
        > $file
    popd > /dev/null
}

download_and_extract_file_from_github() {
    targetFolder=${2:-~}
    url=https://raw.githubusercontent.com/klibio/bootstrap/$branch/$1
    echo "downloading and extract $url"
    curl -sSL \
        $url \
        | tar xvz -C $targetFolder > /dev/null
}

ask_user() {
    file=$1
    targetFolder=${2:-~}
    if [[ $file == *.tar.gz ]]; then
        dirname="${file%.*.*}"
        if [ -d "$targetFolder/$dirname" ] && [ ! $overwrite == true ]; then
            while true; do
                read -p "Do you wish to overwrite $targetFolder/$dirname? " yn
                case $yn in
                    [Yy]* ) download_and_extract_file_from_github $file; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        else
            download_and_extract_file_from_github $file
        fi
    else
        file=$targetFolder/$file
        if [ -f $file ] && [ ! $overwrite == true ]; then 
            while true; do
                read -p "Do you wish to overwrite $file? " yn
                case $yn in
                    [Yy]* ) dl_file_from_github $file; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer [y]es or [n]o.";;
                esac
            done
        else 
            dl_file_from_github $file
        fi
    fi
}

ask_user .klibio.tar.gz
. ~/.klibio/env.sh

ask_user .bashrc

. ~/.klibio/provisionJava.sh

echo "# setup script completed"
