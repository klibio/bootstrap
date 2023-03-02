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

if [[ "$#" == 0 ]]; then
  echo "$(cat <<-EOM
# please provide one or more options of the following applications are available
-o|--ommph
    # launch oomph eclipse installer
-o=<github-org/repo>|--ommph=<github-org/repo>
    # launch oomph eclipse installer with existiong config setup
EOM
)"
fi

# tool variables
oomph=0
eclipse=0

for i in "$@"; do
  case $i in
    -e|--eclipse)
      eclipse=1
      ;;
    -o=*|--oomph=*)
      eclipse_wrkspc="${i#*=}"
      eclipse=1
      shift # past argument=value
      ;;
    -o|--oomph)
      oomph=1
      ;;
    -o=*|--oomph=*)
      oomph_config="${i#*=}"
      oomph=1
      shift # past argument=value
      ;;
    # tool parameter
    -b=*|--branch=*)
      branch="${i#*=}"
      shift # past argument=value
      ;;
    -u|--unsafe)
      unsafe=k
      ;;
    --dev)
      export LOCAL_DEV=HOME_devel
      dev_vm_arg="$(cat <<-EOM
-Duser.home=${HOME}/${LOCAL_DEV} \
-Doomph.setup.user.home.redirect=true
EOM
)"
      echo "###########################################################"
      echo "# LOCAL DEV ACTIVE # start-klibio.sh"
      echo "###########################################################"
      ;;
    --dev=*)
      dev_suffix="${i#*=}"
      shift # past argument=value
      export LOCAL_DEV=HOME_devel_${dev_suffix}
      dev_vm_arg="$(cat <<-EOM
-Duser.home=${HOME}/${LOCAL_DEV} \
-Doomph.setup.user.home.redirect=true
EOM
)"
      echo "###########################################################"
      echo "# LOCAL DEV ACTIVE # start-klibio.sh"
      echo "###########################################################"
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

. ${KLIBIO}/klibio.sh

# testing internet connectivity
if curl --head -sI www.google.com | grep "HTTP/1.1 200 OK" > /dev/null; then 
  echo "internet connection working"; 
else 
  echo "no internet connection - check your proxy settings - exiting"; 
  exit 1
fi

# Command line argument for specifying a Configuration https://www.eclipse.org/forums/index.php/t/1086000/
if [[ ${oomph} -eq 1 ]]; then
  if [[ -f ${oomph_exec} ]]; then
    # minimal oomph version
    setup_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch:-main}/oomph
    if [[ -z ${oomph_config+x} ]]; then
      # delete empty logfiles  
      #find ${KLIBIO}/tool -size 0 -print -delete
      echo "# launching oomph in separate window"
      "${oomph_exec}" \
        -vm "${java_bin}" \
        -vmargs \
        -Doomph.setup.installer.mode=advanced \
          ${dev_vm_arg:-""} \
        -Doomph.redirection.setups=http://git.eclipse.org/c/oomph/org.eclipse.oomph.git/plain/setups/-\>${setup_url}/ \
        2> ${KLIBIO}/tool/${date}_oomph_err.log \
        1> ${KLIBIO}/tool/${date}_oomph_out.log \
        &
    else
      config_url=${setup_url}/config/cfg_${oomph_config/\//_}.setup
      if curl -s${unsafe:-} --output /dev/null --head --fail "${config_url}"; then
        # delete empty logfiles  
        #find ${KLIBIO}/tool -size 0 -print -delete
        echo "# launching oomph in separate window with config ${config_url}"
        "${oomph_exec}" \
          -vm "${java_bin}" \
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
  else  
    echo "no oomph installation found inside ${oomph_exec} - re-install with -o/--oomph"
  fi
fi

if [[ ${eclipse} -eq 1 ]]; then
  if [[ -f ${eclipse_sdk}/${eclipse_exec} ]]; then
      echo "# launching eclipse in separate window"
      "${eclipse_sdk}/${eclipse_exec}" \
        -vm "${java_bin}" \
        2> ${KLIBIO}/tool/${date}_eclipse_err.log \
        1> ${KLIBIO}/tool/${date}_eclipse_out.log \
        &
  else  
    echo "no eclipse installation found inside ${eclipse_sdk}/${eclipse_exec} - re-install with -e/--eclipse"
  fi
fi

set +o nounset  # exit with error on unset variables
set +o errexit  # exit if any statement returns a non-true return value
set +o pipefail # exit if any pipe command is failing
