#!/bin/bash
#
# install klibio bootstrap libraries and tools
#

# activate bash checks
if [[ ${debug:-false} == "true" ]]; then
  set -o xtrace   # activate bash debug
fi
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

script_dir=$(cd "$(dirname "$0")" && pwd)

# tool variables
java=0
oomph=0
overwrite=0

for i in "$@"; do
  case $i in
    # tool parameter
    -j|--java)
      java=1
      ;;
    -o|--oomph)
      oomph=1
      ;;
    # for develoment purposes
    -f|--force)
      overwrite=1
      ;;
    -b=*|--branch=*)
      branch="${i#*=}"
      shift # past argument=value
      ;;
    --dev)
      echo "###########################################################"
      echo -e "\n#\n# LOCAL DEV ACTIVE # install-klibio.sh\n#\n"
      echo "###########################################################"
      export LOCAL_DEV=true
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
if [[ "true" == "${LOCAL_DEV:-false}" ]]; then
  echo "sourcing ${script_dir}/bash/.klibio/klibio.sh"
  . /dev/stdin <<< "$(cat ${script_dir}/bash/.klibio/klibio.sh)"
  install_dir=${script_dir}/HOME
else
  lib_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/klibio.sh
  echo "sourcing ${lib_url}"
  . /dev/stdin <<< "$(curl -fsSL ${lib_url})"
  install_dir=~/.klibio
fi
export install_dir=${install_dir}


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

headline "provision github sources into ${install_dir}"
github_provision .klibio.tar.gz ${install_dir}
github_provision .klibio.sh     ${install_dir}
github_provision .profile       ${install_dir}

if [[ "$OSTYPE" == "darwin"* ]]; then

  brew --version >/dev/null 2>&1; brew_installed=$?
  if [[ 0 != ${brew_installed} ]]; then
    echo "homebrew is not installed, hence installing it - see https://docs.brew.sh/Installation"
    /bin/bash -c " NONINTERACTIVE=1; $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  if [[ -z $(grep "# klibio zsh extension" ~/.zshrc) ]]; then
    headline "configure klibio extension inside ~/.zshrc"
    cat << EOT >> ~/.zshrc

# klibio zsh extension
if [[ -f ${install_dir} ]]; then
  . ${install_dir}/.klibio.sh
fi
EOT
  else
    headline "klibio extension already inside ~/.zshrc"
  fi
else
    if [[ -z $(grep "# klibio bash extension" ~/.bashrc) ]]; then
      headline "configure klibio extension inside ~/.zshrc"
      cat << EOT >> ~/.bashrc

# klibio bash extension
if [[ -f ${install_dir} ]]; then
  . ${install_dir}/.klibio.sh
fi
EOT
  else
    headline "klibio extension already inside ~/.bashrc"
  fi
fi

provide_tool () {
  tool=$1
  provision_tool=${install_dir}/provision-${tool}.sh
  headline "provision ${tool} start"
  . ${provision_tool}
  headline "provision ${tool} finished"
}

((${java}))  && provide_tool java  || echo "skip java provisioning"
((${oomph})) && provide_tool oomph || echo "skip oomph provisioning"

headline "klibio setup script completed"
