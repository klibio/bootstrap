#!/bin/bash
set -Eeuo pipefail

export KLIBIO=$HOME/.klibio
toolsDir=$(realpath -s "$KLIBIO/tool")

source $KLIBIO/env.sh

 # check for curl and exit if not available
if which curl > /dev/null; then
    echo "using available curl"
  else
    echo "curl is not available - please install it from https://curl.se/"
    exit 1;
fi

if [ ! -f $toolsDir/$jq ]; then
  mkdir -p $toolsDir
  curl -s -C - --output $toolsDir/$jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/$jq
  jq=$toolsDir/$jq
fi
echo "using jq version: `$jq --version`"
