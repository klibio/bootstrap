#!/bin/bash
#
# download and extract the os/arch specific latest eclipse installer version (including JRE)
# archive is extracted into ${KLIBIO}/tool/eclipse-installer
#
prov_oomph_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

if [[ HOME_devel* == ${LOCAL_DEV:-false} ]]; then
  echo "###########################################################"
  echo "# LOCAL DEV ACTIVE # provision-oomph.sh"
  echo "###########################################################"
fi

# setup script env
. ${prov_oomph_dir}/eclib.sh
set-env
unset_proxy

download_url="https://download.eclipse.org/oomph/products/latest/eclipse-inst-jre-${oomph_suffix}"
output_file="eclipse-inst-jre-${oomph_suffix}"

if [ ! -f ${tools_archives}/${output_file} ]; then
  mkdir -p ${tools_archives}
  echo -e "#\n# downloading ${output_file} to ${tools_archives}\n#\n"
  curl -skSL \
      ${download_url} \
      > ${tools_archives}/${output_file}
fi

if [[ -f "${oomph_exec}" ]]; then
  echo -e "#\n# using existing installer from ${oomph_dir}\n#\n"
else 
  echo -e "#\n# extracting ${output_file} to ${oomph_dir}\n#\n"
  mkdir -p ${oomph_dir}
  case ${java_os} in
    linux)
      tar -zxvf "${tools_archives}/${output_file}" -C "${oomph_dir}"
      ;;
    mac)
      tar -xvf "${tools_archives}/${output_file}" -C "${oomph_dir}"
      ;;
    windows)
      unzip -qq -o -d "${oomph_dir}" "${tools_archives}/${output_file}"
      ;;
    *)
    echo -e "#\n# OS is none of the supported linux|windows|mac. Aborting... \n#\n" && exit 1
    ;;
  esac
fi
