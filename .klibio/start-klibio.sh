#!/bin/bash
#
# start klibio applications/tools  
#
script_dir=$(dirname $(readlink -f $0))
# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

# load library
. klibio.sh

if [[ "$#" == 0 ]]; then
  echo "$(cat <<-EOM
# please provide one or more options of the following applications are available
-o|--ommph  oomph eclipse installer
-o=<github-org/repo>|--ommph=<github-org/repo>  oomph eclipse installer with oomph config
EOM
)"
fi

# tool variables
oomph=0
git_org=klibio
git_host=github.com
project=

for i in "$@"; do
  case $i in
    # tool parameter
    -o|--oomph)
      oomph=1
      ;;
    -o=*|--oomph=*)
      # input form example: https://github.com/klibio/bootstrap
      # use everything after the last slash as project
      project=$(echo ${i#*=} | cut -d '/' -f 5)

      git_org=$(echo ${i#*=} | cut -d '/' -f 4)

      # use everything before the last slash as host
      git_host=$(echo ${i#*=} | cut -d '/' -f 3)
      oomph=1
      shift # past argument=value
      ;;
    # tool parameter
    -u|--unsafe)
      unsafe=k
      ;;
    --dev)
      dev_vm_arg="$(cat <<-EOM
-Duser.home=${HOME}/oomph_devel \
-Doomph.setup.user.home.redirect=true
EOM
)"
      ;;
    --dev=*)
      dev_suffix="${i#*=}"
      shift # past argument=value
      dev_vm_arg="$(cat <<-EOM
-Duser.home=${HOME}/oomph_devel_${dev_suffix} \
-Doomph.setup.user.home.redirect=true
EOM
)"
      ;;
    # default for unknown parameter
    -*|--*)
      echo "unknow option $i provided"
      exit 1
      ;;
    *)
      ;;
  esac
done

# testing internet connectivity
if curl --head -sI www.google.com | grep "HTTP/1.1 200 OK" > /dev/null; then 
  echo "internet connection working"; 
else 
  echo "no internet connection - check your proxy settings - exiting"; 
  exit 1
fi

# Command line argument for specifying a Configuration https://www.eclipse.org/forums/index.php/t/1086000/
if [[ ${oomph} -eq 1 ]]; then
  # minimal oomph version
  jvm=$(echo ${KLIBIO}/java/ee/JAVA17${java_home_suffix:-}/bin)
  oomph_exec=$(echo "${KLIBIO}/tool/eclipse-installer/${oomph_exec_suffix}")
  setup_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch:-main}/oomph
  if [[ -z ${oomph_config+x} ]]; then
    echo "# launching oomph in separate window"
    "${oomph_exec}" \
      -vm "${jvm}" \
      -vmargs \
      -Doomph.setup.installer.mode=advanced \
        ${dev_vm_arg:-""} \
      -Doomph.redirection.setups=http://git.eclipse.org/c/oomph/org.eclipse.oomph.git/plain/setups/-\>${setup_url}/ \
      2> ${KLIBIO}/tool/${date}_oomph_err.log \
      1> ${KLIBIO}/tool/${date}_oomph_out.log \
      &
   else
     config_url=${setup_url}/config/cfg_${git_host}_${git_org}_${project}.setup
     if curl -s${unsafe:-} --output /dev/null --head --fail "${config_url}"; then
       echo "# launching oomph in separate window with config ${config_url}"
       "${oomph_exec}" \
         -vm "${jvm}" \
         ${config_url} \
         -vmargs \
         -Doomph.setup.installer.mode=advanced \
           ${dev_vm_arg:-""} \
         -Doomph.redirection.setups=http://git.eclipse.org/c/oomph/org.eclipse.oomph.git/plain/setups/-\>${setup_url}/ \
         2> ${KLIBIO}/tool/${date}_oomph_err.log \
         1> ${KLIBIO}/tool/${date}_oomph_out.log \
         &
    else
      echo "no oomph config for provided repo existing: ${config_url}"
    fi

   fi
fi

set +o nounset  # exit with error on unset variables
set +o errexit  # exit if any statement returns a non-true return value
set +o pipefail # exit if any pipe command is failing
