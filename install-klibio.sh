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
eclipse=0
java=0
oomph=0
overwrite=false
unsafe=""

for i in "$@"; do
  case $i in
    # tool parameter
    -e|--eclipse)
      eclipse=1
      ;;
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
    -u|--unsafe)
      export unsafe=k
      ;;
    -b=*|--branch=*)
      branch="${i#*=}"
      shift # past argument=value
      ;;
    --dev)
      export LOCAL_DEV=HOME_devel
      ;;
    --dev=*)
      dev_suffix="${i#*=}"
      export LOCAL_DEV=HOME_devel_${dev_suffix}
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

# define and set KLIBIO root folder
branch=${branch:-main}
if [[ ${LOCAL_DEV:-false} == HOME_devel* ]]; then
  script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-.}" )" &> /dev/null && pwd )
  export HOME=${script_dir}/${LOCAL_DEV}
  export KLIBIO=${HOME}/.klibio
  mkdir -p ${KLIBIO}
  cp -rf ${script_dir}/.klibio/* ${KLIBIO}
# to be reviewed
#  mkdir -p ${KLIBIO}/.ssh
#  cp ${HOME}/.ssh/id_rsa ${KLIBIO}/.ssh/id_rsa
  echo "sourcing klibio.sh"
  . ${KLIBIO}/klibio.sh
  echo "###########################################################"
  echo "# LOCAL DEV ACTIVE # install-klibio.sh inside ${LOCAL_DEV} "
  echo "###########################################################"
else
  export KLIBIO=$(echo ${HOME}/.klibio)
  lib_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/.klibio/klibio.sh
  echo "# sourcing klibio library - ${lib_url}"
  install_dir=${HOME}
  $(curl -fs${unsafe:-}SLO ${lib_url})
  . klibio.sh
  rm klibio.sh
fi

# https://manytools.org/hacker-tools/ascii-banner/
headline "$(cat <<-EOM
###########################################################

██╗  ██╗██╗     ██╗██████╗ ██╗ ██████╗    
██║ ██╔╝██║     ██║██╔══██╗██║██╔═══██╗   
█████╔╝ ██║     ██║██████╔╝██║██║   ██║   
██╔═██╗ ██║     ██║██╔══██╗██║██║   ██║   
██║  ██╗███████╗██║██████╔╝██║╚██████╔╝   
╚═╝  ╚═╝╚══════╝╚═╝╚═════╝ ╚═╝ ╚═════╝    
███████╗███████╗████████╗██╗   ██╗██████╗ 
██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████╗█████╗     ██║   ██║   ██║██████╔╝
╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
███████║███████╗   ██║   ╚██████╔╝██║     
╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     

###########################################################
EOM
)"

headline "provision sources into ${KLIBIO}"
if [[ ${LOCAL_DEV:-false} == HOME_devel* ]]; then
  tar xvzf .klibio.tar.gz -C $(dirname ${KLIBIO})
else
  github_provision .klibio.tar.gz $(dirname ${KLIBIO})
fi

if [[ "$OSTYPE" == "darwin"* ]]; then

  set +o errexit
  brew --version >/dev/null 2>&1; brew_installed=$?
  set -o errexit
  if [[ 0 != ${brew_installed} ]]; then
    echo "homebrew is not installed, but required - see https://docs.brew.sh/Installation"
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
    headline "klibio extension already inside ~/.zshrc"
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
    headline "klibio extension already inside ~/.bashrc"
  fi
fi

provide_tool () {
  tool=$1
  provision_tool=${KLIBIO}/provision-${tool}.sh
  headline "provision ${tool} start"
  . ${provision_tool}
  headline "provision ${tool} finished"
}

${KLIBIO}/provision-tools.sh
((${eclipse})) && provide_tool eclipse || echo "skip eclipse provisioning"
((${java}))    && provide_tool java    || echo "skip java provisioning"
((${oomph}))   && provide_tool oomph   || echo "skip oomph provisioning"

. ${KLIBIO}/.klibio_profile

headline "klibio setup script completed"

set +o nounset  # exit with error on unset variables
set +o errexit  # exit if any statement returns a non-true return value
set +o pipefail # exit if any pipe command is failing
