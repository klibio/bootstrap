#!/bin/bash
#
# install klibio bootstrap libraries and tools
#
script_dir=$(dirname $(readlink -e ${BASH_SOURCE:-$(pwd)}))
# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

# tool variables
java=0
oomph=0
overwrite=false

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
      overwrite=true
      ;;
    -b=*|--branch=*)
      branch="${i#*=}"
      shift # past argument=value
      ;;
    --dev)
      echo "###########################################################"
      echo "# LOCAL DEV ACTIVE # install-klibio.sh"
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
  . ${script_dir}/bash/.klibio/klibio.sh
  install_dir=${script_dir}/HOME
else
  lib_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/klibio.sh
  echo "# sourcing klibio library - ${lib_url}"
  install_dir=~
  $(curl -fsSLO ${lib_url})
  . klibio.sh
  rm klibio.sh
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

headline "provision sources into ${install_dir}"
if [[ "true" == "${LOCAL_DEV:-false}" ]]; then
  tar xvzf ${script_dir}/.klibio.tar.gz -C ${install_dir}
else
  github_provision .klibio.tar.gz   ${install_dir}
fi

if [[ "$OSTYPE" == "darwin"* ]]; then

  brew --version >/dev/null 2>&1; brew_installed=$?
  if [[ 0 != ${brew_installed} ]]; then
    echo "homebrew is not installed, hence installing it - see https://docs.brew.sh/Installation"
    /bin/bash -c "NONINTERACTIVE=1; $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
    /bin/bash -c "NONINTERACTIVE=1; brew install coreutils"
  fi

  if [[ -z $(grep "# klibio zsh extension" ${install_dir}/.zshrc 2>/dev/null) ]]; then
    headline "configure klibio extension inside ${install_dir}/.zshrc"
    cat << EOT >> ~/.zshrc

# klibio zsh extension
if [[ -f ${install_dir}/.klibio_profile ]]; then
  . ${install_dir}/.klibio_profile
fi
EOT
  else
    headline "klibio extension already inside ${install_dir}/.zshrc"
  fi
else
    if [[ -z $(grep "# klibio bash extension" ${install_dir}/.bashrc 2>/dev/null) ]]; then
      headline "configure klibio extension inside ${install_dir}/.bashrc"
      cat << EOT >> ~/.bashrc

# klibio bash extension
if [[ -f ${install_dir}/.klibio_profile ]]; then
  . ${install_dir}/.klibio_profile
fi
EOT
  else
    headline "klibio extension already inside ${install_dir}/.bashrc"
  fi
fi

provide_tool () {
  tool=$1
  provision_tool=${install_dir}/.klibio/provision-${tool}.sh
  headline "provision ${tool} start"
  . ${provision_tool}
  headline "provision ${tool} finished"
}

((${java}))  && provide_tool java  || echo "skip java provisioning"
((${oomph})) && provide_tool oomph || echo "skip oomph provisioning"

headline "klibio setup script completed"
