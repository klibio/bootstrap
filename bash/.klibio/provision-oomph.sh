#!/bin/bash

### Description of content
# This file provides functionality that will download the latest eclipse installer
# including a JRE for the os of the system it is executed on.
# The eclipse-installer archive will be extracted into ~/.klibio/tool/eclipse-installer

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


download_url="https://download.eclipse.org/oomph/products/latest/eclipse-inst-jre-${eclInstaller}"
output_file="eclipse-inst-jre-${eclInstaller}"


echo -e "#\n# downloading $output_file to $tools_archives\n#\n"
curl -sSL \
    ${download_url} \
    > ${tools_archives}/${output_file}

echo -e "#\n# extracting $output_file to $installer_dir\n#\n"
if [[ ${os} == linux ]]; then
    tar -zxvf "eclipse-inst-jre-linux64.tar.gz" -C "${installer_dir}"
elif [[ ${os} == windows ]]; then
    unzip -qq -d "${installer_dir}" "${tools_archives}/${output_file}"
elif [[ ${os} == mac ]]; then
    tar -zxvf "eclipse-inst-jre-linux64.tar.gz" -C "${installer_dir}"
else
    echo -e "#\n# OS is none of linux/windows/mac. Aborting... \n#\n" && exit 1
fi