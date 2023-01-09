#!/bin/bash
set -Eeuo pipefail

javaRestAPI=https://api.adoptium.net

export KLIBIO=$HOME/.klibio
javaDir=$(echo "$KLIBIO/java")

source $KLIBIO/env.sh
source $KLIBIO/provideTools.sh

function provisionJava() {
  javaVersion=${1:-17}
  javaImageType=${2:-jdk}
  javaArchitecture=${3:-x64}
  currentJava=JAVA$javaVersion
  declare $currentJava=java$javaVersion

  echo -e "#\n# prepare $javaImageType $currentJava for $os and arch $javaArchitecture\n#\n"
  declare "url=$javaRestAPI/v3/assets/latest/$javaVersion/hotspot?architecture=$javaArchitecture&image_type=$javaImageType&os=$os&vendor=eclipse"
  if [ ! -d "$javaDir" ]; then mkdir -p $javaDir 2>/dev/null; fi
  pushd $javaDir
  curl -sSX 'GET' "$url" > resp.json
#  if [ "$?" -ne "0" ]; then echo -e "failing release info download from url=$url\n hence exiting script"; fi
  declare javaArchiveLink=$( cat resp.json  | $jq -r '.[0].binary.package.link' )
  declare javaArchiveName=$( cat resp.json  | $jq -r '.[0].binary.package.name' )
  declare javaReleaseName=$( cat resp.json  | $jq -r '.[0].release_name' )
  rm resp.json
  echo -e "parsed following values from $url\n  javaArchiveLink=$javaArchiveLink\n  javaArchiveName=$javaArchiveName\n  javaReleaseName=$javaReleaseName\n"

  declare archiveDir=$javaDir/archives
  mkdir -p $archiveDir && pushd $archiveDir
  if [ ! -f $javaArchiveName ]; then
    curl -s -C - -k -O -L $javaArchiveLink
  fi

  declare installDir=$javaDir/exec
  declare linkDir=$javaDir/ee
  mkdir -p $installDir && mkdir -p $linkDir && pushd $installDir
  if [ -d "$installDir/$javaReleaseName" ]; then
    echo -e "#\n# using existing Java from $installDir/$javaReleaseName\n#\n"
  else 
    echo -e "#\n# extracting Java into $installDir/$javaReleaseName\n#\n"
    if [[ $javaArchiveName == *.zip ]]; then
      unzip -qq -d "$installDir" "$archiveDir/$javaArchiveName"
    elif [[ $javaArchiveName == *.tar.gz ]]; then
      tar xvzf "$archiveDir/$javaArchiveName" -C "$installDir"
    else
      echo -e "#\n# the archive format could not be recognized \n#\n"
    fi
    if [ -f $linkDir/$currentJava ]; then rm $linkDir/$currentJava; fi
    ln -s "$installDir/$javaReleaseName" $linkDir/$currentJava
  fi

  popd
}

echo -e "\n##############################\n# Java setup on $os\n##############################\n"
provisionJava 8
provisionJava 11
provisionJava 17
