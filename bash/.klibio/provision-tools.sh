#!/bin/bash
#
# provision tools
#
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
# activate bash checksset -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

if [[ "true" == "${LOCAL_DEV:-false}" ]]; then
  echo "###########################################################"
  echo " LOCAL DEV ACTIVE # provision-tools.sh"
  echo "###########################################################"
fi

# load library
. ${script_dir}/klibio.sh

tools_dir=$(echo "${script_dir}/tool")

jq_download_link=https://github.com/stedolan/jq/releases/download/jq-1.6

 # check for curl and exit if not available
if which curl > /dev/null; then
    echo "using available curl"
  else
    echo "curl is not available - please install it from https://curl.se/"
    exit 1;
fi

export jq=${tools_dir}/${jq_exec}
if [ ! -f ${jq} ]; then
  mkdir -p ${tools_dir}  && pushd ${tools_dir} >/dev/null 2>&1
  curl -s -C - -O -L ${jq_download_link}/${jq_exec}
  chmod u+x ${jq}
  popd >/dev/null 2>&1
fi
echo "using jq version: $(${jq} --version)"

