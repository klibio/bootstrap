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
  export jq_exec=jq-win64.exe                 # others
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
  export jq_exec=jq-osx-amd64                 # others
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
  export jq_exec=jq-linux64                   # others
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


###########################################################
# color settings for console output
###########################################################

NC='\033[0m' # no color
BLUE='\033[0;34m';
RED='\e[31m';
GREEN='\e[42m';

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
    printf -v x '%-60s' "$1"; echo -ne "${BLUE}$(date +%H:%M:%S) $x${NC}"
  else
    printf -v x '%-60s' "$1"; echo -ne "$(date +%H:%M:%S) $x"
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

###########################################################
# github dowload util functions
###########################################################

download_file_from_github() {
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

download_and_extract_file_from_github() {
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

github_provision() {
    file=$1
    target_folder=$2
    if [[ $file == *.tar.gz ]]; then
        dirname="${file%.*.*}"
        if [[ -d "${target_folder}/${dirname}" && ${overwrite} != "true" ]]; then
            while true; do
                read -p "Do you wish to overwrite ${target_folder}/${dirname}? " yn
                case $yn in
                    [Yy]* ) download_and_extract_file_from_github ${file} ${target_folder}; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        else
            download_and_extract_file_from_github ${file} ${target_folder}
        fi
    else
        file=${target_folder}/${file}
        if [[ -f ${file}  && ${overwrite} != "true" ]]; then 
            while true; do
                read -p "Do you wish to overwrite $file? " yn
                case $yn in
                    [Yy]* ) download_file_from_github ${file} ${target_folder}; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer [y]es or [n]o.";;
                esac
            done
        else 
            download_file_from_github ${file} ${target_folder}
        fi
    fi
}

confirm() {
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

launch_ssh_agent () {
  echo "launching ssh agent"
  env=~/.ssh/agent.env

  agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }
  
  agent_start () {
      (umask 077; ssh-agent >| "$env")
      . "$env" >| /dev/null ; }
  
  agent_load_env
  
  # agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
  agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)
  
  if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
      agent_start
      ssh-add
  elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
      ssh-add
  fi

  unset env
}
