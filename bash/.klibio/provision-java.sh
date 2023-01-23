#!/bin/bash

if [[ ${DEBUG} = true ]]; then
  set -o xtrace   # activate debug
fi
# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

# load library
. /dev/stdin <<< "$(cat ~/.klibio/klibio.bash)"

java_rest_api=https://api.adoptium.net
java_dir=$(echo "${KLIBIO}/java")

. /dev/stdin <<< "$(cat ~/.klibio/klibio.bash)"
. /dev/stdin <<< "$(cat ~/.klibio/provision-tools.sh)"

provisionJava() {
  java_version=${1:-17}
  java_image_type=${2:-jdk}
  java_architecture=${3:-x64}
  current_java=JAVA${java_version}
  declare $current_java=java${java_version}

  echo -e "#\n# prepare ${java_image_type} ${current_java} for ${os} and arch ${java_architecture}\n#\n"
  declare "url=${java_rest_api}/v3/assets/latest/${java_version}/hotspot?architecture=${java_architecture}&image_type=${java_image_type}&os=${os}&vendor=eclipse"
  if [ ! -d "${java_dir}" ]; then mkdir -p ${java_dir} 2>/dev/null; fi
  pushd ${java_dir} >/dev/null 2>&1
  curl -sSX 'GET' "$url" > resp.json
#  if [ "$?" -ne "0" ]; then echo -e "failing release info download from url=$url\n hence exiting script"; fi
  declare java_archive_link=$( cat resp.json  | $jq -r '.[0].binary.package.link' )
  declare java_archive_name=$( cat resp.json  | $jq -r '.[0].binary.package.name' )
  declare java_release_name=$( cat resp.json  | $jq -r '.[0].release_name' )
  rm resp.json
 
  if [[ ${DEBUG} = true ]]; then
    echo -e "parsed following values from $url\n  java_archive_link=${java_archive_link}\n  java_archive_name=${java_archive_name}\n  java_release_name=${java_release_name}\n"
  fi

  declare archive_dir=${java_dir}/archives
  mkdir -p ${archive_dir} >/dev/null 2>&1 && pushd ${archive_dir} >/dev/null 2>&1
  if [ ! -f ${java_archive_name} ]; then
    curl -s -C - -k -O -L ${java_archive_link}
  fi
  popd >/dev/null 2>&1

  declare install_dir=${java_dir}/exec
  declare link_dir=${java_dir}/ee
  mkdir -p ${install_dir} >/dev/null 2>&1 && mkdir -p ${link_dir} >/dev/null 2>&1 && pushd ${install_dir} >/dev/null 2>&1
  if [ -d "${install_dir}/${java_release_name}" ]; then
    echo -e "#\n# using existing Java from ${install_dir}/${java_release_name}\n#\n"
  else 
    echo -e "#\n# extracting Java into ${install_dir}/${java_release_name}\n#\n"
    if [[ ${java_archive_name} == *.zip ]]; then
      unzip -qq -d "${install_dir}" "${archive_dir}/${java_archive_name}"
    elif [[ ${java_archive_name} == *.tar.gz ]]; then
      tar xvzf "${archive_dir}/${java_archive_name}" -C "${install_dir}"
    else
      echo -e "#\n# the archive format could not be recognized \n#\n"
    fi
    if [ -f ${link_dir}/${current_java} ]; then rm ${link_dir}/${current_java}; fi
    ln -s "${install_dir}/${java_release_name}" ${link_dir}/${current_java}
  fi
  popd >/dev/null 2>&1
  popd >/dev/null 2>&1
}

echo -e "\n##############################\n# Java setup on $os\n##############################\n"
provisionJava 8
provisionJava 11
provisionJava 17
