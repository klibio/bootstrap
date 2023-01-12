#!/bin/bash
#
# install klibio bootstrap libraries and tools
#

# activate bash checks
set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

script_dir=$(cd "$(dirname "$0")" && pwd)
overwrite=false

# load library
branch=$(git rev-parse --abbrev-ref HEAD) && branch=${branch:-main}
. /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/klibio.bash)"

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

cat << EOT
###########################################################

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

###########################################################
EOT

headline "provision github sources"
github_provision .klibio.tar.gz
github_provision .bash_klibio
github_provision .bash_aliases

headline "provision java"
. /dev/stdin <<< "$(cat ~/.klibio/provision-java.sh)"

headline "configure ~/.bashrc"
cat << EOT >> ~/.bashrc
# source the klibio bash extension
if [ -f ~/.bash_klibio ]; then
  . ~/.bash_klibio
fi
EOT

headline "klibio setup script completed"
