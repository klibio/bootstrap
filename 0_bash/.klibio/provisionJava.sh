#!/bin/bash
set -Eeuo pipefail
scriptDir=$(cd "$(dirname "$0")" && pwd)
export KLIBIO="$scriptDir"
  javaDir=$(realpath -s "$scriptDir/java")
 toolsDir=$(realpath -s "$scriptDir/tool")

if [[ "$OSTYPE" == "msys" ]]; then
  os=windows
  jq=jq-win64.exe
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  os=mac
  jq=jq-osx-amd64
fi
if [[ "$OSTYPE" == "linux"* ]]; then
  os=linux
  jq=jq-linux64
fi

echo -e "\n##############################\n# Java setup on $os\n##############################\n"

# check for curl and exit if not available
if which curl > /dev/null; then
    echo "using available curl"
  else
    echo "curl is not available - please install it from https://curl.se/"
    exit 1;
fi

if [ ! -f $toolsDir/$jq ]; then
  mkdir -p $toolsDir
  curl -s -C - --output $toolsDir/$jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/$jq
  jq=$toolsDir/$jq
fi
echo "using jq version: `$jq --version`"

function provisionJava() {
  javaVersion=${1:-17}
  javaImageType=${2:-jdk}
  javaArchitecture=${3:-x64}
  currentJava=JAVA$javaVersion
  declare $currentJava=java$javaVersion

  echo -e "#\n# prepare $javaImageType $currentJava for $os and arch $javaArchitecture\n#\n"
  declare "url=https://api.adoptopenjdk.net/v3/assets/latest/$javaVersion/hotspot?architecture=$javaArchitecture&image_type=$javaImageType&os=$os&vendor=adoptopenjdk"
  if [ ! -d "$javaDir" ]; then mkdir -p $javaDir 2>/dev/null; fi
  pushd $javaDir
  curl -sSX 'GET' "$url" > resp.json
#  if [ "$?" -ne "0" ]; then echo -e "failing release info download from url=$url\n hence exiting script"; fi
  declare javaArchiveLink=$( cat resp.json  | jq -r '.[0].binary.package.link' )
  declare javaArchiveName=$( cat resp.json  | jq -r '.[0].binary.package.name' )
  declare javaReleaseName=$( cat resp.json  | jq -r '.[0].release_name' )
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
    unzip -qq -d "$installDir" "$archiveDir/$javaArchiveName"
    if [ -f $linkDir/$currentJava ]; then rm $linkDir/$currentJava; fi
    ln -s "$installDir/$javaReleaseName" $linkDir/$currentJava
  fi

  popd
}

# Java 8
provisionJava 8
provisionJava 11
provisionJava 17

echo "# DEBUG ENV - START" && env | sort | grep -E -i "^(JAVA|java)" && echo "# DEBUG ENV - END"
