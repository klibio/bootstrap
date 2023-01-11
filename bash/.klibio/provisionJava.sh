#!/bin/bash

# activate bash checks
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

# load library
branch=${branch:-main}
. /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/lib.bash)"

java_rest_api=https://api.adoptium.net

KLIBIO=${KLIBIO:=$(echo $HOME/.klibio)}
export KLIBIO=$KLIBIO
java_dir=$(echo "$KLIBIO/java")

. $KLIBIO/env.sh
. $KLIBIO/provideTools.sh

provisionJava() {
  java_version=${1:-17}
  java_image_type=${2:-jdk}
  java_architecture=${3:-x64}
  current_java=JAVA$java_version
  declare $current_java=java$java_version

  echo -e "#\n# prepare $java_image_type $current_java for $os and arch $java_architecture\n#\n"
  declare "url=$java_rest_api/v3/assets/latest/$java_version/hotspot?architecture=$java_architecture&image_type=$java_image_type&os=$os&vendor=eclipse"
  if [ ! -d "$java_dir" ]; then mkdir -p $java_dir 2>/dev/null; fi
  pushd $java_dir
  curl -sSX 'GET' "$url" > resp.json
#  if [ "$?" -ne "0" ]; then echo -e "failing release info download from url=$url\n hence exiting script"; fi
  declare java_archive_link=$( cat resp.json  | $jq -r '.[0].binary.package.link' )
  declare java_archive_name=$( cat resp.json  | $jq -r '.[0].binary.package.name' )
  declare java_release_name=$( cat resp.json  | $jq -r '.[0].release_name' )
  rm resp.json
 
 debug_execute echo -e "parsed following values from $url\n  java_archive_link=$java_archive_link\n  java_archive_link=$java_archive_link\n  java_release_name=$java_release_name\n"

  declare archiveDir=$java_dir/archives
  mkdir -p $archiveDir && pushd $archiveDir
  if [ ! -f $java_archive_link ]; then
    curl -s -C - -k -O -L $java_archive_link
  fi

  declare installDir=$java_dir/exec
  declare linkDir=$java_dir/ee
  mkdir -p $installDir && mkdir -p $linkDir && pushd $installDir
  if [ -d "$installDir/$java_release_name" ]; then
    echo -e "#\n# using existing Java from $installDir/$java_release_name\n#\n"
  else 
    echo -e "#\n# extracting Java into $installDir/$java_release_name\n#\n"
    if [[ $java_archive_link == *.zip ]]; then
      unzip -qq -d "$installDir" "$archiveDir/$java_archive_link"
    elif [[ $java_archive_link == *.tar.gz ]]; then
      tar xvzf "$archiveDir/$java_archive_link" -C "$installDir"
    else
      echo -e "#\n# the archive format could not be recognized \n#\n"
    fi
    if [ -f $linkDir/$current_java ]; then rm $linkDir/$current_java; fi
    ln -s "$installDir/$java_release_name" $linkDir/$current_java
  fi

  popd
}

echo -e "\n##############################\n# Java setup on $os\n##############################\n"
provisionJava 8
provisionJava 11
provisionJava 17
