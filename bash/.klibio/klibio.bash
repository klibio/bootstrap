#!/bin/bash

# activate debugging
set -o xtrace   # activate debug

###########################################################
# shell variables
###########################################################

export KLIBIO=${KLIBIO:=$(echo ~/.klibio)}
export PATH=$PATH:$KLIBIO

# general 
export          date=$(date +'%Y.%m.%d-%H.%M.%S')

export        branch=$(git rev-parse --abbrev-ref HEAD)
export       vcs_ref=$(git rev-list -1 HEAD)
export vcs_ref_short=$(git describe --dirty --always)

# export variable into build agents e.g. github runner, azure runner
declare -a build_agent_vars=(
  "date"
  "branch" "vcs_ref" "vcs_ref_short" # git variables
)
if [ -v "AGENT_ID" ]; then
  echo "running inside workflow pipeline - hence set variables"
  for i in "${build_agent_vars[@]}"; do
    echo "##vso[task.setvariable variable=${i^^}]${!i}"
  done
fi

# OS specific environment variables

if [[ "$OSTYPE" == "msys" ]]; then
  export os=windows
  export jq=jq-win64.exe
  export eclInstaller=win64.zip
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  export os=mac
  export jq=jq-osx-amd64
  export eclInstaller=mac64.tar.gz
  export java_home_suffix=/Contents/Home
fi
if [[ "$OSTYPE" == "linux"* ]]; then
  export os=linux
  export jq=jq-linux64
  export eclInstaller=linux64.tar.gz
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
  if [ -t 1 ]; then # identify if stdout is terminal
    echo -ne "${BLUE}#\n# $1\n#\n${NC}"
  else
    echo -ne "#\n# $1\n#\n"
  fi
}

padout() {
  if [ -t 1 ]; then # identify if stdout is terminal
    printf -v x '%-60s' "$1"; echo -ne "${BLUE}$(date +%H:%M:%S) $x${NC}"
  else
    printf -v x '%-60s' "$1"; echo -ne "$(date +%H:%M:%S) $x"
  fi
}

err() {
  if [ -t 1 ]; then # identify if stdout is terminal
    echo -e " - ${RED}FAILED${NC}"
  else
    echo -e " - FAILED"
  fi
}

succ() {
  if [ -t 1 ]; then # identify if stdout is terminal
    echo -e " - ${GREEN}SUCCESS${NC}"
  else
    echo -e " - SUCCESS"
  fi
}

is_debug() {
    if ${DEBUG:-false}; then
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

github_provision() {
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
                    [Yy]* ) download_file_from_github $file; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer [y]es or [n]o.";;
                esac
            done
        else 
            download_file_from_github $file
        fi
    fi
}
