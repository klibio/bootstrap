#!/bin/bash
#
# library functions
#

# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
###########################################################
# exporting shell variables
###########################################################

# git variables (if inside git repo)
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null ) || branch=${branch:-main}
export       vcs_ref=$(git rev-list -1 HEAD 2>/dev/null )
export vcs_ref_short=$(git describe --dirty --always 2>/dev/null )
export        gh_url="https://raw.githubusercontent.com/klibio/bootstrap/${branch}"

# general 
if [[ HOME_devel* == ${LOCAL_DEV:-false} ]]; then
  echo "###########################################################"
  echo "# LOCAL DEV ACTIVE # klibio.sh"
  echo "###########################################################"
  mkdir -p ${script_dir}/HOME
  export KLIBIO=${KLIBIO:-$(echo ${script_dir}/HOME/.klibio)}
else
  export KLIBIO=${KLIBIO:-$(echo ~/.klibio)}
fi
export PATH=${PATH}:${KLIBIO}
export date=$(date +'%Y.%m.%d-%H.%M.%S')

# export variable into build agents e.g. github runner, azure runner
declare -a build_agent_vars=(
  "date"
  "branch" "vcs_ref" "vcs_ref_short" # git variables
)
if [[ ! -z ${AGENT_ID+x} ]]; then
  echo "running inside workflow pipeline - hence set variables"
  for i in "${build_agent_vars[@]}"; do
    key=$(echo $i | tr '[:lower:]' '[:upper:]')
    value=$(echo ${!i})
    echo "##vso[task.setvariable variable=${key}]${value}"
  done
fi

###########################################################
# OS specific environment variables
###########################################################

if [[ $OSTYPE == msys ]]; then
  # WINDOWS
  export osgi_os=win32                        # osgi
  export osgi_ws=win32                        # osgi
  export osgi_arch=x86_64                     # osgi
  export java_os=windows                      # java
  export java_arch=x64                        # java
  export eclipse_exec=eclipse.exe             # eclipse
  export oomph_exec_suffix=eclipse-inst.exe   # oomph
  export oomph_suffix=win64.zip               # oomph
  export jq_exec=jq-windows-amd64.exe         # others
  export htmlq_exec=htmlq.exe                 # others
fi

if [[ "$OSTYPE" == darwin* ]]; then
  # MACOSX
  export osgi_os=macosx                       # osgi
  export osgi_ws=cocoa                        # osgi
  export java_os=mac                          # java
  export java_home_suffix=/Contents/Home      # java
  if [[ "$(uname -a)" == *"arm"* ]]; then
    export osgi_arch=aarch64                  # osgi
    export oomph_suffix=mac-aarch64.tar.gz    # oomph
    export java_arch=aarch64                  # java
  else
    export osgi_arch=x86_64                   # osgi
    export oomph_suffix=mac64.tar.gz          # oomph
    export java_arch=x64                      # java
  fi
  export eclipse_exec=Eclipse.app/Contents/MacOS/eclipse.exe                    # eclipse
  export oomph_exec_suffix="Eclipse Installer.app/Contents/MacOS/eclipse-inst"  # oomph
  export jq_exec=jq-macos-amd64                                                # others
  export htmlq_exec=htmlq                     # others
fi

if [[ "$OSTYPE" == linux* ]]; then
  # LINUX
  export osgi_os=linux                        # osgi
  export osgi_ws=gtk                          # osgi
  export java_os=linux                        # java
  if [[ "$(uname -a)" == *"arm"* ]]; then
    # oomph var
    export oomph_suffix=linux-aarch64.tar.gz  # oomph
    export java_arch=aarch64                  # java
  else
    export oomph_suffix=linux64.tar.gz        # oomph
    export java_arch=x64                      # java
  fi
  export eclipse_exec=eclipse                 # eclipse
  export oomph_exec_suffix=eclipse-inst.exe   # oomph
  export jq_exec=jq-linux-amd64             # others
  export htmlq_exec=htmlq                     # others
fi

# more variables - mind order, due to re-use
export tools_dir="${KLIBIO}/tool"                                        # others
export tools_archives="${tools_dir}/archives"                            # others
export eclipse_platform_version=4.26                                     # eclipse
export eclipse_sdk=${KLIBIO}/eclipse_${eclipse_platform_version}/eclipse # eclipse
export oomph_dir="${tools_dir}/eclipse-installer"                        # oomph
export oomph_exec="${oomph_dir}/${oomph_exec_suffix}"                    # oomph
export java_bin="${KLIBIO}/java/ee/JAVA17${java_home_suffix:-}/bin"      # java

export ant_version="1.10.14"                                            # ant
export ant_name="apache-ant-${ant_version}"                             # ant
export ant_dir="${tools_dir}/${ant_name}"                               # ant
export mvn_version="3.9.4"                                              # mvn
export mvn_name="apache-maven-${mvn_version}"                           # mvn
export mvn_dir="${tools_dir}/${mvn_name}"                               # mvn

###########################################################
# proxy configuration
###########################################################

# Function to configure the proxy settings on windows
function unset_proxy() {
  if [[ ! -z ${ENFORCE_PROXY_USAGE+x} ]]; then
    echo "using preconfigured proxies"
  else
    echo "unsetting all proxies"
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
  fi
}

# Function to configure the proxy settings on windows
function configure_proxy() {
  if [ "$proxy_pac_executed" ]; then
    echo "proxy evaluation already executed - using $https_proxy"
  else
    # evaluate proxy settings
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

    reg_key="HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    reg_value="AutoConfigURL"

    # Read the value of AutoConfigURL from the Windows Registry (mind // for win bash)
    proxy_pac_url=$(reg query "$reg_key" //v "$reg_value" 2>/dev/null | awk -F ' ' '/REG_SZ/ {print $NF}')

    # Check if AutoConfigURL value exists and is not empty
    if [ "$proxy_pac_url" ]; then
      echo "proxy.pac file is configured - url: $proxy_pac_url"
    else
      echo "NO proxy.pac file is found - no proxy configured"
      return 1
    fi
    parse_proxy_entries "$proxy_pac_url"
    export proxy_pac_executed=true
  fi
}

# Function to test internet connectivity
function test_connectivity() {
  proxy=$1
  timeout=2
  http_connected=false
  https_connected=false
  echo -ne "check internet connectivity via proxy $proxy "
  echo -ne "# http"
  curl -k -L --proxy $proxy --max-time $timeout http://www.google.com &>/dev/null
  if [[ $? == 0 ]]; then
    http_connected=true
    echo -ne " - OK "
  else
    echo -ne " - FAILED "
  fi
  if [[ "$http_connected" == "true" ]]; then
    echo -ne "# https"
    curl -k -L --proxy $proxy --max-time $timeout https://www.google.com &>/dev/null
    if [[ $? == 0 ]]; then
      https_connected=true
      echo -e " - OK"
    else
      echo -e " - FAILED"
    fi
  else
    echo -e ""
  fi

  if [[ "$http_connected" == "true" ]] && [[ "$https_connected" == "true" ]]; then
    echo "configuring http_proxy / https_proxy $proxy"
    export http_proxy=$proxy
    export https_proxy=$proxy
    export "curl_proxy=--proxy $proxy"
    return 0
  fi
  return 1
}

# Function to parse proxy entries from an URL using curl and return them as an array
function parse_proxy_entries() {
  url="$1"

  # Download the proxy PAC file using curl
  echo "downloading proxy PAC file from: $url"
  pac_file=$(mktemp)
  # mind that no proxy must be used here
  if ! curl -k -s "$url" -o "$pac_file"; then
    echo "failed to download the proxy PAC file."
    return 1
  fi

  # Extract proxy entries from the PAC file
  proxy_entries=$(grep -Eo 'PROXY [^;]+' "$pac_file" | sed 's/PROXY //' | sed 's/"//')

  # Check if proxy entries are found
  if [[ -n $proxy_entries ]]; then
    # Convert proxy entries to an array
    IFS=$'\n' read -r -d '' -a proxy_array <<<"$proxy_entries"
    for proxy in "${proxy_array[@]}"; do
      if test_connectivity "$proxy"; then
        echo found working proxy $proxy
        return 0
      fi
    done
    echo "no proxy could connect to internet - open edge browser and access https://gooogle.com" and try again
    exit 1
  else
    echo "no proxy entries found in the PAC file."
  fi

  # Clean up the temporary PAC file
  rm -f "$pac_file"
}

###########################################################
# color settings for console output
###########################################################

NC='\033[0m' # no color
BLUE='\033[0;34m'
RED='\e[31m'
GREEN='\e[42m'

# write a 3 lines spanning headline to standard out
headline() {
  if [[ -t 1 ]]; then # identify if stdout is terminal
    echo -ne "${BLUE}#\n# $1\n#\n${NC}"
  else
    echo -ne "#\n# $1\n#\n"
  fi
}

padout() {
  if [[ -t 1 ]]; then # identify if stdout is terminal
    printf -v x '%-60s' "$1"
    echo -ne "${BLUE}$(date +%H:%M:%S) $x${NC}"
  else
    printf -v x '%-60s' "$1"
    echo -ne "$(date +%H:%M:%S) $x"
  fi
}

err() {
  if [[ -t 1 ]]; then # identify if stdout is terminal
    echo -e " - ${RED}FAILED${NC}"
  else
    echo -e " - FAILED"
  fi
}

succ() {
  if [[ -t 1 ]]; then # identify if stdout is terminal
    echo -e " - ${GREEN}SUCCESS${NC}"
  else
    echo -e " - SUCCESS"
  fi
}

is_debug() {
    if ${debug:-false}; then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

# enterprise network drive workaround
function assure_local_home() {
  if [[ $HOME == /h/ ]]; then
    echo "env HOME variable is refering to network share $HOME"
    if [[ "${USERPROFILE+x}" = "x" ]]; then
      xUSERPROFILE=${USERPROFILE//\\//}
      export "HOME=/${xUSERPROFILE//:/}"
      echo "changing to %USERPROFILE%=${HOME}"
    else
      echo "configure your HOME variable to local folder e.g. '%USERPROFILE%'"
      exit 1
    fi
  fi
}
function assure_global_properties() {
  if [[ ! -f ~/.global.properties ]]; then
    echo "configure your .ec_global.properties inside your HOME folder"
    echo "download file from here https://raw.githubusercontent.com/klibio/bootstrap/${branch}/template/ec_global.properties"
    echo "store it inside ~/.ec_global.properties (MIND the leading DOT)"
    echo "configure the contents with your credentials and try again"
    exit 1
  fi
}
###########################################################
# github dowload util functions
###########################################################

function download_file_from_github() {
    file=$(basename -- "$1")
    target_folder=$2
    if  [[ ${overwrite} == "true" ]]; then rm -rf ${target_folder}/${file} >/dev/null 2>&1; fi
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null ) || branch=${branch:-main}
    url=${gh_url}/bash/${file}
    pushd ${target_folder} >/dev/null 2>&1
    echo "downloading and save into ${target_folder}/${file}"
    curl -s${unsafe:-}SL \
        ${url} \
        > ${file}
    popd >/dev/null 2>&1
}

function download_and_extract_file_from_github() {
    file=$1
    target_folder=$2
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null ) || branch=${branch:-main}
    url=${gh_url}/${file}
    echo "downloading and extract ${file} into ${target_folder}"
    mkdir -p ${target_folder}
    curl -s${unsafe:-}SL \
        ${url} \
        | tar xvz -C ${target_folder} > /dev/null
}

function github_provision() {
  file=$1
  target_folder=$2
  if [[ $file == *.tar.gz ]]; then
    dirname="${file%.*.*}"
    if [[ -d "${target_folder}/${dirname}" && ${overwrite} != "true" ]]; then
      while true; do
        read -p "Do you wish to overwrite ${target_folder}/${dirname}? " yn
        case $yn in
        [Yy]*)
          download_and_extract_file_from_github ${file} ${target_folder}
          break
          ;;
        [Nn]*) break ;;
        *) echo "Please answer yes or no." ;;
        esac
      done
    else
      download_and_extract_file_from_github ${file} ${target_folder}
    fi
  else
    file=${target_folder}/${file}
    if [[ -f ${file} && ${overwrite} != "true" ]]; then
      while true; do
        read -p "Do you wish to overwrite $file? " yn
        case $yn in
        [Yy]*)
          download_file_from_github ${file} ${target_folder}
          break
          ;;
        [Nn]*) break ;;
        *) echo "Please answer [y]es or [n]o." ;;
        esac
      done
    else
      download_file_from_github ${file} ${target_folder}
    fi
    fi
}

function confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "${response}" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

function launch_ssh_agent() {
  echo "launching ssh agent"
  env=~/.ssh/agent.env

  agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }
  
  agent_start () {
    (
      umask 077
      ssh-agent >|"$env"
    )
    . "$env" >|/dev/null
  }
  
  agent_load_env
  
  # agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
  agent_run_state=$(
    ssh-add -l >|/dev/null 2>&1
    echo $?
  )
  
  if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
      agent_start
      ssh-add
  elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
      ssh-add
  fi

  unset env
}

# arg1 is the path of the properties file to read
# arg2 (true/false) defines if an env variable should be replaced in case it already exists
function readProperties {
  if [ -f $1 ]; then
    echo "export env vars from properties file $1"
    readPropertyFile $1 $2
  else
    usage
  fi
}

function readPropertyFile {
  filename=$(basename $1)
  localfile="${TEMP:-/tmp}/${filename}"
  cp -f $1 ${localfile}
  # delete comments
  sed -i '/#.*$/d' ${localfile}
  sed -i '/`/d' ${localfile}  # remove lines with backtick
  sed -i '/\\/d' ${localfile} # remove lines with backtick
  # delete empty lines
  trimmed_file=$(cat ${localfile} | awk 'NF')
  while IFS='=' read -r key value; do
    # test key if comment and non-zero
    if [[ ! $key = \#* && -n $key ]]; then
      # as a workaround, - are replaced by _ in order to enable loading of properties
      key=$(echo $key | tr '-' '_')
      value=$(echo $value | awk '{$1=$1};1') # remove leading blanks
      # as a workaround, bash special chars are escaped
      # value=$(echo $value | printf %q $value)
      if [ $2 == "true" ] || [ -z "$(eval echo \${${key}:-})" ]; then
        eval ${key}="${value}"
      else
        eval echo '${key} is already set and is not changed!'
      fi
      if [[ "true" == ${debug:-false} ]]; then
        echo "export ${key}=${value}"
      fi
      export ${key}=${value}
    fi
  done <<<"${trimmed_file}"
  rm -rf ${localfile}
}

function set-env {
  # check for curl and exit if not available
  if which curl >/dev/null; then
    echo "curl is available"
  else
    echo "curl is not available - please install it from https://curl.se/"
    exit 1
  fi

  global_props=~/.global.properties
  
  #file_permissions=$(stat -c '%a' ${global_props})
  #if [ "$file_permissions" == "600" ]; then
  #  echo "The file hugo.props has correct permissions (0600)."
  #else
  #  echo "ATTENTION: The file ${global_props} does not have correct permissions (0600)."
  #  echo "Change permissions with the following command:"
  #  echo "chmod 0600 ${global_props}"
  #  exit 1
  #fi
  if [ -f ${global_props} ]; then
    readProperties ${global_props} false
  else
    echo "please configure ${global_props}"
    return
  fi

  echo -e "#\n# environment variables\n#\n"
  env | sort \
      | grep -E '^artifactory_|^git_|engine|^proxy|^http' \
      | sed -r 's/(.*)_token=(.*)/\1_token=<set-but-hidden>/'    
  env | sort \
      | grep -E '^HOME=|.*_OPTS='

  export _env_available_
}

urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            ' ') printf "%%20" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    
    LC_COLLATE=$old_lc_collate
}