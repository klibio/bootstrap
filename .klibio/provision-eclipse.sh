#!/bin/bash
#
# library functions
#

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
  echo "# LOCAL DEV ACTIVE # provision-eclipse.sh"
  echo "###########################################################"
fi

# load library
. klibio.sh

case ${osgi_os} in
  linux)
    eclipse_skd_archive=eclipse-SDK-${eclipse_platform_version}-${osgi_os}-${osgi_ws}-${osgi_arch}.tar.gz
    eclipse_exec=eclipse
    ;;
  macosx)
    eclipse_skd_archive=eclipse-SDK-${eclipse_platform_version}-${osgi_os}-${osgi_ws}-${osgi_arch}.tar.gz
    eclipse_exec=/Contents/Home/eclipse
    ;;
  win32)
    eclipse_skd_archive=eclipse-SDK-${eclipse_platform_version}-${osgi_os}-${osgi_arch}.zip
    eclipse_exec=eclipse.exe
    ;;
  *)
    echo -e "#\n# OS is none of the supported (linux|win32|macosx). Aborting... \n#\n" && exit 1
    ;;
esac

# parse latest eclipse
search_text="/eclipse/updates/${eclipse_platform_version}/R"
eclipse_platform_link=$(curl -s https://download.eclipse.org/eclipse/updates/${eclipse_platform_version}/ \
  | ${tools_dir}/${htmlq_exec} --attribute href a \
  | grep "^${search_text}")

eclipse_platform_timestamp=$( echo ${eclipse_platform_link} | cut -d "/" -f 5 | cut -d "-" -f 3)
eclipse_sdk_url="https://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-${eclipse_platform_version}-${eclipse_platform_timestamp}/${eclipse_skd_archive}&r=1"

if [ ! -f ${tools_archives}/${eclipse_skd_archive} ]; then
  echo -e "#\n# downloading ${eclipse_skd_archive} to ${tools_archives}\n#\n"
  curl -s${unsafe:-}SL \
      ${eclipse_sdk_url} \
      > ${tools_archives}/${eclipse_skd_archive}
  else
    echo -e "#\n# using existing ${tools_archives}/${eclipse_skd_archive}\n#\n"
fi

eclipse_sdk_dir=${tools_dir}/eclipse_${eclipse_platform_version}

if [[ -f "${eclipse_sdk_dir}/eclipse/${eclipse_exec}" ]]; then
  echo -e "#\n# using existing eclipse from ${eclipse_sdk_dir}\n#\n"
else 
 echo -e "#\n# extracting ${eclipse_skd_archive} to ${eclipse_sdk_dir}\n#\n"
 mkdir -p ${eclipse_sdk_dir}
  case ${java_os} in
    linux)
      tar -zxvf "${tools_archives}/${eclipse_skd_archive}" -C "${eclipse_sdk_dir}"
      ;;
    windows)
      unzip -qq -o -d "${eclipse_sdk_dir}" "${tools_archives}/${eclipse_skd_archive}"
      ;;
    mac)
      tar -xvf "${tools_archives}/${eclipse_skd_archive}" -C "${eclipse_sdk_dir}"
      ;;
    *)
    echo -e "#\n# OS is none of the supported linux|windows|mac. Aborting... \n#\n" && exit 1
    ;;
  esac
fi