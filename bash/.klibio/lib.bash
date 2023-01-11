#!/bin/bash

# activate bash checks
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

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