#!/bin/bash
#
# download and extract the os/arch specific latest eclipse installer version (including JRE)
# archive is extracted into ${ECDEV}/tool/eclipse-installer
#
prov_buildtools_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi

if [[ HOME_devel* == ${LOCAL_DEV:-false} ]]; then
  echo "###########################################################"
  echo "# LOCAL DEV ACTIVE # provision-oomph.sh"
  echo "###########################################################"
fi

# setup script env
. ${prov_buildtools_dir}/eclib.sh
set-env
unset_proxy

output_file="${mvn_name}-bin.zip"
download_url="${artifactory_url}/cec-sdk-release/origin/maven/apache/org/maven2/org/apache/maven/apache-maven/${mvn_version}/${output_file}"

if [ ! -f ${tools_archives}/${output_file} ]; then
  mkdir -p ${tools_archives}
  echo -e "#\n# downloading ${download_url}\n#\n"
  curl -u ${artifactory_username}:${artifactory_token} -skSL \
      ${download_url} \
      > ${tools_archives}/${output_file}
fi

if [[ -d "${mvn_dir}" ]]; then
  echo -e "#\n# using existing maven from ${mvn_dir}\n#\n"
else 
  echo -e "#\n# extracting ${output_file} to ${mvn_dir}\n#\n"
  mkdir -p ${mvn_dir}
  unzip -qq -o -d "${tools_dir}" "${tools_archives}/${output_file}"
fi

output_file="${ant_name}-bin.zip"
download_url="${artifactory_url}/cec-sdk-release/origin/dlcdn.apache.org/ant/binaries/${output_file}"

if [ ! -f ${tools_archives}/${output_file} ]; then
  mkdir -p ${tools_archives}
  echo -e "#\n# downloading ${download_url}\n#\n"
  curl -u ${artifactory_username}:${artifactory_token} -skSL \
      ${download_url} \
      > ${tools_archives}/${output_file}
fi

if [[ -d "${ant_dir}" ]]; then
  echo -e "#\n# using existing maven from ${ant_dir}\n#\n"
else 
  echo -e "#\n# extracting ${output_file} to ${ant_dir}\n#\n"
  mkdir -p ${ant_dir}
  unzip -qq -o -d "${tools_dir}" "${tools_archives}/${output_file}"
fi
