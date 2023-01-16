#!/bin/bash
#
# download and extract the os/arch specific latest eclipse installer version (including JRE)
# archive is extracted into ${KLIBIO}/tool/eclipse-installer

# activate bash checks
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

# load library
. /dev/stdin <<< "$(cat ~/.klibio/klibio.bash)"

tools_dir=$(echo "${KLIBIO}/tool")
tools_archives="${tools_dir}/archives"
installer_dir="${tools_dir}/eclipse-installer"

mkdir -p ${installer_dir}
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
  case ${os} in
    linux)
      tar -zxvf "eclipse-inst-jre-${oomph_suffix}" -C "${installer_dir}"
      ;;
    windows)
      unzip -qq -o -d "${installer_dir}" "${tools_archives}/${output_file}"
      ;;
    mac)
      tar -xvf "eclipse-inst-jre-${oomph_suffix}" -C "${installer_dir}"
      ;;
    *)
      echo -e "#\n# OS is none of the supported linux|windows|mac. Aborting... \n#\n" && exit 1
      exit 1
  esac
fi
