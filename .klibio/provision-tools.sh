#!/bin/bash
#
# provision tools
#
prov_tool_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
# activate bash checksset -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

if [[ HOME_devel* == ${LOCAL_DEV:-false} ]]; then
  echo "###########################################################"
  echo " LOCAL DEV ACTIVE # provision-tools.sh"
  echo "###########################################################"
fi

# setup script env
. ${prov_tool_dir}/eclib.sh
set-env
unset_proxy

jq_download_link=${artifactory_url}/cec-sdk-release/origin/github.com/jqlang/jq/releases/download/jq-1.7

 # check for curl and exit if not available
if which curl > /dev/null; then
    echo "using available curl"
  else
    echo "curl is not available - please install it from https://curl.se/"
    exit 1;
fi

export jq=${tools_dir}/${jq_exec}
if [[ ! -f "${jq}" ]]; then
  mkdir -p ${tools_dir} >/dev/null 2>&1
  echo -e "#\n# downloading jq from ${jq_download_link}/${jq_exec}\n#\n" 
  curl -sk -C - -o ${tools_dir}/${jq_exec} -L ${jq_download_link}/${jq_exec} ||
    echo -e "#\n# failed downloading jq from ${jq_download_link}/${jq_exec}\n#\n"
  if [[ -f "${jq}" ]]; then
    chmod u+x ${jq}
  fi
fi
${jq} --version

export htmlq=${tools_dir}/${htmlq_exec}
htmlq_url=https://github.com/mgdm/htmlq/releases/download/v0.4.0
mkdir -p ${tools_archives} >/dev/null 2>&1
pushd ${tools_archives} >/dev/null 2>&1
case ${osgi_os} in
  linux)
    archive=htmlq-x86_64-linux.tar.gz
    curl -sk -O -L ${htmlq_url}/${archive} ||
      echo -e "#\n# failed downloading jq from ${htmlq_url}/${archive}\n#\n"
    if [ -f "${tools_archives}/${archive}" ]; then
      tar -xvf "${tools_archives}/${archive}" -C "${tools_dir}"
    fi
    ;;
  macosx)
    archive=htmlq-x86_64-darwin.tar.gz
    curl -sk -O -L ${htmlq_url}/${archive} ||
      echo -e "#\n# failed downloading jq from ${htmlq_url}/${archive}\n#\n"
    if [ -f "${tools_archives}/${archive}" ]; then
      tar -xvf "${tools_archives}/${archive}" -C "${tools_dir}"
    fi
    ;;
  win32)
    archive=htmlq-x86_64-windows.zip
    curl -sk -O -L ${htmlq_url}/${archive} ||
      echo -e "#\n# failed downloading htmlq from ${htmlq_url}/${archive}\n#\n"
    if [ -f "${tools_archives}/${archive}" ]; then
      unzip -qq -o -d "${tools_dir}" "${tools_archives}/${archive}"
    fi
    ;;
  *)
    echo -e "#\n# OS is none of the supported (linux|win32|macosx). Aborting... \n#\n" && exit 1
    ;;
esac
popd >/dev/null 2>&1
echo "using `${htmlq} --version`"
