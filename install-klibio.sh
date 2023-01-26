#!/bin/bash
#
# install klibio bootstrap libraries and tools
#

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

# define and set KLIBIO root folder
branch=${branch:-main}
if [[ "true" == "${LOCAL_DEV:-false}" ]]; then
  script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-.}" )" &> /dev/null && pwd )
  export KLIBIO=${script_dir}/HOME/.klibio
  mkdir -p $(dirname ${script_dir}/HOME/.ssh)
  cp ~/.ssh/id_rsa ${script_dir}/HOME/.ssh
  echo "sourcing klibio.sh"
  . ${script_dir}/bash/.klibio/klibio.sh
else
  export KLIBIO=$(echo ~/.klibio)
  lib_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/klibio.sh
  echo "# sourcing klibio library - ${lib_url}"
  install_dir=~
  $(curl -fsSLO ${lib_url})
  . klibio.sh
  rm klibio.sh
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

headline "provision sources into ${KLIBIO}"
if [[ "true" == "${LOCAL_DEV:-false}" ]]; then
  tar xvzf .klibio.tar.gz -C $(dirname ${KLIBIO})
else
  github_provision .klibio.tar.gz $(dirname ${KLIBIO})
fi

if [[ "$OSTYPE" == "darwin"* ]]; then

  brew --version >/dev/null 2>&1; brew_installed=$?
  if [[ 0 != ${brew_installed} ]]; then
    echo "homebrew is not installed, hence installing it - see https://docs.brew.sh/Installation"
    /bin/bash -c "NONINTERACTIVE=1; $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
    brew list | grep coreutil >/dev/null 2>&1; coreutils_installed=$?
    if [[ 0 != ${coreutils_installed} ]]; then
      echo "coreutils in homebrew is not installed, hence installing it"
      /bin/bash -c "NONINTERACTIVE=1; brew install coreutils"
    fi
  fi

  if [[ -z $(grep "# klibio zsh extension" ~/.zshrc 2>/dev/null) ]]; then
    headline "configure klibio extension inside ~/.zshrc/.zshrc"
    cat << EOT >> ~/.zshrc

# klibio zsh extension
export KLIBIO=${KLIBIO}
export PATH=\${KLIBIO}:\${PATH}
if [[ -f \${KLIBIO}/.klibio_profile ]]; then
  . \${KLIBIO}/.klibio_profile
fi
EOT
  else
    headline "klibio extension already inside $(dirname ${KLIBIO})/.zshrc"
  fi
else
    if [[ -z $(grep "# klibio bash extension" ~/.bashrc 2>/dev/null) ]]; then
      headline "configure klibio extension inside ~/.bashrc"
      cat << EOT >> ~/.bashrc

# klibio bash extension
export KLIBIO=${KLIBIO}
export PATH=\${KLIBIO}:\${PATH}
if [[ -f \${KLIBIO}/.klibio_profile ]]; then
  . \${KLIBIO}/.klibio_profile
fi
EOT
  else
    headline "klibio extension already inside $(dirname ${KLIBIO})/.bashrc"
  fi
fi

provide_tool () {
  tool=$1
  provision_tool=$(dirname ${KLIBIO})/.klibio/provision-${tool}.sh
  headline "provision ${tool} start"
  . ${provision_tool}
  headline "provision ${tool} finished"
}

((${java}))  && provide_tool java  || echo "skip java provisioning"
((${oomph})) && provide_tool oomph || echo "skip oomph provisioning"

headline "klibio setup script completed"
