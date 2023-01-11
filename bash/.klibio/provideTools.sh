#!/bin/bash

# activate bash checks
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

KLIBIO=${KLIBIO:=$(echo $HOME/.klibio)}
tools_dir=$(echo "$KLIBIO/tool")

jq_download_link=https://github.com/stedolan/jq/releases/download/jq-1.6

. $KLIBIO/env.sh

 # check for curl and exit if not available
if which curl > /dev/null; then
    echo "using available curl"
  else
    echo "curl is not available - please install it from https://curl.se/"
    exit 1;
fi

if [ ! -f $tools_dir/$jq ]; then
  mkdir -p $tools_dir
  curl -s -C - --output $tools_dir/$jq -L ${jq_download_link}/$jq
  chmod u+x $tools_dir/$jq
  jq=$tools_dir/$jq
fi
echo "using jq version: $($jq --version)"
