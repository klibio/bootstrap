#!/bin/bash
#
# download and extract the lts java versions for this os and platform
#
prov_java_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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
  echo "# LOCAL DEV ACTIVE # provision-java.sh"
  echo "###########################################################"
fi

# load library
. ${prov_java_dir}/klibio.sh
set-env

. ${prov_java_dir}/provision-tools.sh

java_rest_api=https://api.adoptium.net
java_dir=$(echo "${KLIBIO}/java")

add_certificates_to_cacerts() {
  local java_keytool=${1}/bin/keytool
  local certificate=${2}
  local certificate_dir=${KLIBIO}/certificates
  if [[ "$1" == *"8" ]]; then
    set +o errexit  # exit if any statement returns a non-true return value
    ${java_keytool} \
      -list \
      -keystore ${1}/jre/lib/security/cacerts \
      -storepass changeit \
      -noprompt \
      -alias ${certificate} >/dev/null 2>&1

    if [[ "$?" == "1" ]]; then
      echo "adding ${certificate} into ${1}/jre/lib/security/cacerts"
      ${java_keytool} \
        -import \
        -trustcacerts \
        -keystore ${1}/jre/lib/security/cacerts \
        -storepass changeit \
        -noprompt \
        -alias ${certificate} \
        -file ${certificate_dir}/${certificate}.crt >/dev/null 2>&1
    else
      echo "alias ${certificate} is already contained inside ${1}/jre/lib/security/cacerts"
    fi
    set -o errexit  # exit if any statement returns a non-true return value

  else
    set +o errexit  # exit if any statement returns a non-true return value
    ${java_keytool} \
      -list \
      -cacerts \
      -storepass changeit \
      -noprompt \
      -alias ${certificate} >/dev/null 2>&1

    if [[ "$?" == "1" ]]; then
      echo "adding ${certificate} into ${1}/jre/lib/security/cacerts"
      ${java_keytool} \
      -import \
      -cacerts \
      -trustcacerts \
      -storepass changeit \
      -noprompt \
      -alias ${certificate} \
      -file ${certificate_dir}/${certificate}.crt >/dev/null 2>&1
    else
      echo "alias ${certificate} is already contained inside ${1}/lib/security/cacerts"
    fi
    set -o errexit  # exit if any statement returns a non-true return value

  fi
}

add_certificates() {
  local java_dir=$1
  local certificate_dir=${KLIBIO}/certificates
  local certificate_files=$(ls .1 ${certificate_dir}/*.crt 2>/dev/null)
  if [[ "${certificate_files}" == "" ]]; then
    echo -e "   no certificate files found\n"
  else
    for cert_file in ${certificate_files}; do
      local certificate="$(echo $(basename $cert_file) | sed -n 's/\.crt$//p')"
      add_certificates_to_cacerts "$java_dir" "$certificate"
    done
  fi
}

provision_java_from_internet() {
  java_version=${1:-17}
  java_image_type=${2:-jdk}
  java_architecture=${3:-x64}
  java_ee=JAVA${java_version}
  declare $java_ee=java${java_version}

  echo -e "#\n# prepare ${java_image_type} ${java_ee} for ${java_os} and arch ${java_architecture}\n#\n"
  declare "url=${java_rest_api}/v3/assets/latest/${java_version}/hotspot?architecture=${java_architecture}&image_type=${java_image_type}&os=${java_os}&vendor=eclipse"
  if [ ! -d "${java_dir}" ]; then mkdir -p ${java_dir} 2>/dev/null; fi
  pushd ${java_dir} >/dev/null 2>&1
  curl -s${unsafe:-}SX 'GET' "$url" > resp.json
#  if [ "$?" -ne "0" ]; then echo -e "failing release info download from url=$url\n hence exiting script"; fi
  declare java_archive_link=$( cat resp.json  | $jq -r '.[0].binary.package.link' )
  declare java_archive_name=$( cat resp.json  | $jq -r '.[0].binary.package.name' )
  declare java_release_name=$( cat resp.json  | $jq -r '.[0].release_name' )
  rm resp.json
 
  if [[ ${debug:-false} == "true" ]]; then
    echo -e "parsed following values from $url\n  java_archive_link=${java_archive_link}\n  java_archive_name=${java_archive_name}\n  java_release_name=${java_release_name}\n"
  fi

  declare archive_dir=${java_dir}/archives
  mkdir -p ${archive_dir} >/dev/null 2>&1 && pushd ${archive_dir} >/dev/null 2>&1
  if [ ! -f ${java_archive_name} ]; then
    curl -s${unsafe:-} -C - -O -L ${java_archive_link}
  fi
  popd >/dev/null 2>&1

  declare install_dir=${java_dir}/exec
  declare link_dir=${java_dir}/ee
  mkdir -p ${install_dir} >/dev/null 2>&1 && mkdir -p ${link_dir} >/dev/null 2>&1 \
    && pushd ${install_dir} >/dev/null 2>&1
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

    echo -e "#\n# create symbolink link ${link_dir}/${java_ee}\n#\n"
    if [ -f ${link_dir}/${java_ee} ]; then rm ${link_dir}/${java_ee}; fi
    ln -s "${install_dir}/${java_release_name}" ${link_dir}/${java_ee}
    if [[ ${java_os} == mac ]]; then
      ln -s ${link_dir}/${java_ee}/Contents/Home/bin ${link_dir}/${java_ee}/bin
    fi

    echo -e "#\n# add certificates to cacerts inside ${link_dir}/${java_ee}/lib/security/cacerts\n#\n"
    add_certificates "${link_dir}/${java_ee}"
  fi
  popd >/dev/null 2>&1
  popd >/dev/null 2>&1
}

provision_java_from_artifactory() {
  
  regex='jdk-?([0-9]*).*'
  [[ $1 =~ ${regex} ]]
  java_version=${BASH_REMATCH[1]}

  regex='jdk-?(.*)'
  [[ $1 =~ ${regex} ]]
  java_release_name=${BASH_REMATCH[1]}
  java_release_name=${java_release_name//+/_}
  java_release_name=${java_release_name//-/}
  java_image_type=${2:-jdk}
  java_architecture=${3:-x64}
  java_ee=JAVA${java_version}
  declare $java_ee=java${java_version}

  if [[ ${java_os} == windows ]]; then
    java_archive_suffix=.zip
  else 
    java_archive_suffix=.tar.gz
  fi
  declare java_archive_name=OpenJDK${java_version}U-jdk_${java_architecture}_${java_os}_hotspot_${java_release_name}${java_archive_suffix}
  declare java_archive_link="https://github.com/adoptium/temurin${java_version}-binaries/releases/tag/$(urlencode $1)/${java_archive_name}"
  echo -e "#\n# downloading Java from ${java_archive_link}\n#\n"
  
  pushd ${java_dir} >/dev/null 2>&1
  declare archive_dir=${java_dir}/archives
  mkdir -p ${archive_dir} >/dev/null 2>&1 && pushd ${archive_dir} >/dev/null 2>&1
  if [ ! -f ${java_archive_name} ]; then
    curl -u${artifactory_username}:${artifactory_token} -sk -C - -O -L ${java_archive_link}
  fi
  popd >/dev/null 2>&1

  declare install_dir=${java_dir}/exec
  declare link_dir=${java_dir}/ee
  mkdir -p ${install_dir} >/dev/null 2>&1 
  mkdir -p ${link_dir} >/dev/null 2>&1
  pushd ${install_dir} >/dev/null 2>&1
  if [ -d "${install_dir}/$1" ]; then
    echo -e "#\n# using existing Java from ${install_dir}/$1\n#\n"
  else 
    echo -e "#\n# extracting Java into ${install_dir}/$1\n#\n"
    if [[ ${java_archive_name} == *.zip ]]; then
      unzip -qq -d "${install_dir}" "${archive_dir}/${java_archive_name}"
    elif [[ ${java_archive_name} == *.tar.gz ]]; then
      tar xvzf "${archive_dir}/${java_archive_name}" -C "${install_dir}"
    else
      echo -e "#\n# the archive format could not be recognized \n#\n"
    fi

    echo -e "#\n# create symbolink link ${link_dir}/${java_ee} from ${install_dir}/$1\n#\n"
    if [ -f ${link_dir}/${java_ee} ]; then rm ${link_dir}/${java_ee}; fi
    ln -s "${install_dir}/$1" ${link_dir}/${java_ee}
    if [[ ${java_os} == mac ]]; then
      ln -s ${link_dir}/${java_ee}/Contents/Home/bin ${link_dir}/${java_ee}/bin
    fi

    echo -e "#\n# add certificates to cacerts inside ${link_dir}/${java_ee}/lib/security/cacerts\n#\n"
    add_certificates "${link_dir}/${java_ee}"
  fi
  popd >/dev/null 2>&1
  popd >/dev/null 2>&1
}

echo -e "\n##############################\n# Java setup on ${java_os}\n##############################\n"

if [[ "aarch64" != "${java_arch}" ]]; then
  provision_java_from_internet "jdk8u382-b05" jdk ${java_arch}
else
  echo "skip java 8 cause not available on architecture aarch64"
fi
provision_java_from_internet "jdk-11.0.20.1+1" jdk ${java_arch}
provision_java_from_internet "jdk-17.0.8.1+1" jdk ${java_arch}
provision_java_from_internet "jdk-21.0.3+9" jdk ${java_arch}