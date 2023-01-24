#!/bin/bash
#
# download and extract the os/arch specific latest eclipse installer version (including JRE)
# archive is extracted into ${KLIBIO}/tool/eclipse-installer

if [[ ${debug:-false} == "true" ]]; then
  set -o xtrace   # activate bash debug
fi
script_dir=$(cd "$(dirname "$0")" && pwd)

# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

if [[ "true" == "${LOCAL_DEV:-false}" ]]; then
  echo "###########################################################"
  echo -e "\n#\n# LOCAL DEV ACTIVE # provision-oomph.sh\n#\n"
  echo "###########################################################"
fi

# load library
. /dev/stdin <<< "$(cat ~/.klibio/klibio.sh)"

tools_dir=$(echo "${KLIBIO}/tool")
tools_archives="${tools_dir}/archives"
installer_dir="${tools_dir}/eclipse-installer"

mkdir -p ${tools_archives}

download_url="https://download.eclipse.org/oomph/products/latest/eclipse-inst-jre-${oomph_suffix}"
output_file="eclipse-inst-jre-${oomph_suffix}"

if [ ! -f ${tools_archives}/${output_file} ]; then
  echo -e "#\n# downloading ${output_file} to ${tools_archives}\n#\n"
  curl -sSL \
      ${download_url} \
      > ${tools_archives}/${output_file}
fi

if [ -d "${installer_dir}" ]; then
  echo -e "#\n# using existing installer from ${installer_dir}\n#\n"
else 
  echo -e "#\n# extracting ${output_file} to ${installer_dir}\n#\n"
  mkdir -p ${installer_dir}
  case ${os} in
    linux)
      tar -zxvf "${tools_archives}/${output_file}" -C "${installer_dir}"
      ;;
    windows)
      unzip -qq -o -d "${installer_dir}" "${tools_archives}/${output_file}"
      ;;
    mac)
      tar -xvf "${tools_archives}/${output_file}" -C "${installer_dir}"
      ;;
    *)
      echo -e "#\n# OS is none of the supported linux|windows|mac. Aborting... \n#\n" && exit 1
      exit 1
  esac
fi
