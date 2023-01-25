#!/bin/bash
#
# klibio library functions
#
script_dir_klibio=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
###########################################################
# exporting shell variables
###########################################################

# git variables (if inside git repo)
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null ) || branch=${branch:-main}
export       vcs_ref=$(git rev-list -1 HEAD 2>/dev/null )
export vcs_ref_short=$(git describe --dirty --always 2>/dev/null )
export        gh_url="https://raw.githubusercontent.com/klibio/bootstrap/${branch}"

# general 
if [[ "true" == "${LOCAL_DEV:-false}" ]]; then
  echo "###########################################################"
  echo "# LOCAL DEV ACTIVE # klibio.sh"
  echo "###########################################################"
  mkdir -p ${script_dir}/HOME
  export KLIBIO=${KLIBIO:-$(echo ${script_dir}/HOME/.klibio)}
else
  export KLIBIO=${KLIBIO:-$(echo ~/.klibio)}
fi
export PATH=$PATH:$KLIBIO
export date=$(date +'%Y.%m.%d-%H.%M.%S')

# export variable into build agents e.g. github runner, azure runner
declare -a build_agent_vars=(
  "date"
  "branch" "vcs_ref" "vcs_ref_short" # git variables
)
if [[ ! -z ${AGENT_ID+x} ]]; then
  echo "running inside workflow pipeline - hence set variables"
  for i in "${build_agent_vars[@]}"; do
    key=$(echo $i | tr '[:lower:]' '[:upper:]')
    value=$(echo ${!i})
    echo "##vso[task.setvariable variable=${key}]${value}"
  done
fi

###########################################################
# OS specific environment variables
###########################################################

if [[ "$OSTYPE" == "msys" ]]; then
  export os=windows
  export jq_exec=jq-win64.exe
  export oomph_exec_suffix=eclipse-inst.exe
  export oomph_suffix=win64.zip
  export java_arch=x64
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  export os=mac
  export jq_exec=jq-osx-amd64
  if [[ "$(uname -a)" == *"arm"* ]]; then
    export oomph_suffix=mac-aarch64.tar.gz
    export java_arch=aarch64
  else
    export oomph_suffix=mac64.tar.gz
    export java_arch=x64
  fi
  export oomph_exec_suffix="Eclipse Installer.app/Contents/MacOS/eclipse-inst"
  export java_home_suffix=/Contents/Home
fi

if [[ "$OSTYPE" == "linux"* ]]; then
  export os=linux
  export jq_exec=jq-linux64
  if [[ "$(uname -a)" == *"arm"* ]]; then
    export oomph_suffix=linux-aarch64.tar.gz
    export java_arch=aarch64
  else
    export oomph_suffix=linux64.tar.gz
    export java_arch=x64
  fi
  export oomph_exec_suffix=eclipse-inst.exe
fi


###########################################################
# color settings for console output
###########################################################

NC='\033[0m' # no color
BLUE='\033[0;34m';
RED='\e[31m';
GREEN='\e[42m';

# write a 3 lines spanning headline to standard out
headline() {
  if [[ -t 1 ]]; then # identify if stdout is terminal
    echo -ne "${BLUE}#\n# $1\n#\n${NC}"
  else
    echo -ne "#\n# $1\n#\n"
  fi
}

padout() {
  if [[ -t 1 ]]; then # identify if stdout is terminal
    printf -v x '%-60s' "$1"; echo -ne "${BLUE}$(date +%H:%M:%S) $x${NC}"
  else
    printf -v x '%-60s' "$1"; echo -ne "$(date +%H:%M:%S) $x"
  fi
}

err() {
  if [[ -t 1 ]]; then # identify if stdout is terminal
    echo -e " - ${RED}FAILED${NC}"
  else
    echo -e " - FAILED"
  fi
}

succ() {
  if [[ -t 1 ]]; then # identify if stdout is terminal
    echo -e " - ${GREEN}SUCCESS${NC}"
  else
    echo -e " - SUCCESS"
  fi
}

is_debug() {
    if ${debug:-false}; then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

###########################################################
# github dowload util functions
###########################################################

download_file_from_github() {
    file=$(basename -- "$1")
    target_folder=$2
    if  [[ ${overwrite} == "true" ]]; then rm -rf ${target_folder}/${file} >/dev/null 2>&1; fi
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null ) || branch=${branch:-main}
    url=${gh_url}/bash/${file}
    pushd ${target_folder} >/dev/null 2>&1
    echo "downloading and save into ${target_folder}/${file}"
    curl -sSL \
        ${url} \
        > ${file}
    popd >/dev/null 2>&1
}

download_and_extract_file_from_github() {
    file=$1
    target_folder=$2
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null ) || branch=${branch:-main}
    url=${gh_url}/${file}
    echo "downloading and extract ${file} into ${target_folder}"
    mkdir -p ${target_folder}
    curl -sSL \
        ${url} \
        | tar xvz -C ${target_folder} > /dev/null
}

github_provision() {
    file=$1
    target_folder=$2
    if [[ $file == *.tar.gz ]]; then
        dirname="${file%.*.*}"
        if [[ -d "${target_folder}/${dirname}" && ${overwrite} != "true" ]]; then
            while true; do
                read -p "Do you wish to overwrite ${target_folder}/${dirname}? " yn
                case $yn in
                    [Yy]* ) download_and_extract_file_from_github ${file} ${target_folder}; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        else
            download_and_extract_file_from_github ${file} ${target_folder}
        fi
    else
        file=${target_folder}/${file}
        if [[ -f ${file}  && ${overwrite} != "true" ]]; then 
            while true; do
                read -p "Do you wish to overwrite $file? " yn
                case $yn in
                    [Yy]* ) download_file_from_github ${file} ${target_folder}; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer [y]es or [n]o.";;
                esac
            done
        else 
            download_file_from_github ${file} ${target_folder}
        fi
    fi
}

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "${response}" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

