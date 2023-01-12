#!/bin/bash

# activate debugging
set -o xtrace   # activate debug

###########################################################
# shell variables
###########################################################

# general 
export          date=$(date +'%Y.%m.%d-%H.%M.%S')

export        branch=$(git rev-parse --abbrev-ref HEAD)
export       vcs_ref=$(git rev-list -1 HEAD)
export vcs_ref_short=$(git describe --dirty --always)

# export variable into build agents e.g. github runner, azure runner
declare -a build_agent_vars=(
  "date"
  ,"branch"
  ,"vcs_ref"
  ,"vcs_ref_short"
)
if [ -v "AGENT_ID" ]; then
  echo "running inside workflow pipeline - hence set variables"
  for i in "${build_agent_vars[@]}"; do
    upper_i=${i^^}
    echo "##vso[task.setvariable variable=${upper_i}]${i}"
  done
  env | sort
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