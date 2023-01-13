#!/bin/bash
#
# install klibio bootstrap libraries and tools
#

# activate bash checks
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

script_dir=$(cd "$(dirname "$0")" && pwd)
# development variable
dev=false
overwrite=false

# tool variables
java=0
oomph=0

for i in "$@"; do
  case $i in
    # tool parameter
    -j|--java)
      java=1
      ;;
    -o|--oomph)
      oomph=1
      ;;

    -f|--force)
      overwrite=true
      echo "# skip user questions and force overwriting of files and directories"
      shift # past argument=value
      ;;
    # for develoment purposes
    -dev)
      dev=true
      shift # past argument=value
      ;;
    -b=*|--branch=*)
      branch="${i#*=}"
      shift # past argument=value
      ;;
    # default for unknown parameter
    -*|--*)
      echo "unknow option $i provided"
      exit 1
      ;;
    *)
      ;;
  esac
done

# load library
branch=${branch:-main}
if [[ "${dev}"=="true" ]]; then
  echo "###########################################################"
  echo -e "\n#\n# LOCAL DEVELOPMENT active\n#\n"
  echo "###########################################################"
  echo "sourcing ${script_dir}/bash/.klibio/klibio.bash"
  . /dev/stdin <<< $(cat ${script_dir}/bash/.klibio/klibio.bash)
else
  lib_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/klibio.bash
  echo "sourcing ${lib_url}"
  . /dev/stdin <<< "$(curl -fsSL ${lib_url})"
fi

headline "$(cat <<-EOM
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
EOM
)"

headline "provision github sources and configure ~/.bashrc"
github_provision .klibio.tar.gz
github_provision .bash_klibio
github_provision .bash_aliases

if [[ -z $(grep "# klibio bash extension" ~/.bashrc) ]]; then
  cat << EOT >> ~/.bashrc

# klibio bash extension
if [ -f ~/.bash_klibio ]; then
  . ~/.bash_klibio
fi
EOT
fi

provide_tool () {
  tool=$1
  provision_tool=~/.klibio/provision-${tool}.sh
  headline "provision ${tool}"
  . ${provision_tool}
}

(($java))  && provide_tool java  || echo "skip java provisioning"
(($oomph)) && provide_tool oomph || echo "skip oomph provisioning"

headline "klibio setup script completed"
