#!/bin/bash
set -Eeuo pipefail

export KLIBIO=$HOME/.klibio
toolsDir=$(realpath -s "$KLIBIO/tool")
toolsArchives=$toolsDir/archives
installerDir=$toolsDir/eclipse-installer

mkdir -p $installerDir
mkdir -p $toolsArchives

source $KLIBIO/env.sh

downloadUrl=https://download.eclipse.org/oomph/products/latest/eclipse-inst-$eclInstaller
outputFile=eclipse-inst-jre-$eclInstaller

echo -e "#\n# downloading $outputFile to $toolsArchives\n#\n"
curl -sSL \
    $downloadUrl \
    > $toolsArchives/$outputFile

echo -e "#\n# extracting $outputFile to $installerDir\n#\n"
if [[ $os == linux ]]; then
    tar -zxvf "eclipse-inst-jre-linux64.tar.gz" -C "$installerDir"
elif [[ $os == windows ]]; then
    unzip -qq -d "$installerDir" "$toolsArchives/$outputFile"
elif [[ $os == mac ]]; then
    tar -zxvf "eclipse-inst-jre-linux64.tar.gz" -C "$installerDir"
else
    echo -e "#\n# OS is none of linux/windows/mac. Aborting... \n#\n" && exit 1
fi