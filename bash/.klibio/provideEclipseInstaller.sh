#!/bin/bash
set -Eeuo pipefail

eclInstaller=""
export KLIBIO=$HOME/.klibio
toolsDir=$(realpath -s "$KLIBIO/tool")
toolsArchives=$toolsDir/archives
source $KLIBIO/env.sh

downloadUrl=https://download.eclipse.org/oomph/products/latest/eclipse-inst-${eclInstaller}
outputFile=eclipse-inst-jre-${eclInstaller}

curl -sSL \
    $downloadUrl \
    > $toolsDir$outputFile

if [[ $os == linux ]]; then
    tar -zxvf "eclipse-inst-jre-linux64.tar.gz" -C "$toolsDir"
elif [[ $os == windows ]]; then
    unzip -qq -d "$toolsDir" "$toolsArchives/$outputFile"
elif [[ $os == mac ]]; then
    tar -zxvf "eclipse-inst-jre-linux64.tar.gz" -C "$toolsDir"
else
    echo -e "#\n# OS is none of linux/windows/mac. Aborting... \n#\n" && exit 1
fi