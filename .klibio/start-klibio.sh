#!/bin/bash
#
# start klibio applications/tools  
#
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

if [[ "$#" == 0 ]]; then
  echo "$(
    cat <<-EOM
# please provide one or more options of the following applications are available
-e=<eclipse_install>|--eclipse=<eclipse_install>
    # launch eclipse from provided install location
-o|--ommph
    # launch oomph eclipse installer
-o=<github-org/repo>|--ommph=<github-org/repo>
    # launch oomph eclipse installer with existiong config setup
EOM
)"
fi

# tool variables

eclipse=0
oomph=0
config_url=
git_org=klibio
git_host=github.com
git_project=
oomph_update_url=https://download.eclipse.org/oomph/updates/release/latest/
setup_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch:-main}/oomph

for i in "$@"; do
  case $i in
    -e=*|--eclipse=*)
      eclipse_install="${i#*=}"
      eclipse_install="${eclipse_install//\\//}"
      eclipse_install="${eclipse_install%/}"
      eclipse_install="/${eclipse_install/:/}"
      eclipse=1
      shift # past argument=value
      ;;
    -o|--oomph)
      oomph=1
      ;;
    -o=*|--oomph=*)
      # input form example: https://github.com/klibio/bootstrap
      # https://<git_host>/<git_org>/git_project>
         git_host=$(echo ${i#*=} | cut -d '/' -f 3)
          git_org=$(echo ${i#*=} | cut -d '/' -f 4)
      git_project=$(echo ${i#*=} | cut -d '/' -f 5)
      # oomph setups
      config_url=${setup_url}/config/cfg_${git_host}_${git_org}_${git_project}.setup
      if ! curl -s${unsafe:-} --output /dev/null --head --fail "${config_url}"; then
        echo "no oomph config available/provided at ${config_url}"
        config_url=
      fi
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
    dev_vm_arg="$(
      cat <<-EOM
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
    dev_vm_arg="$(
      cat <<-EOM
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
  *) ;;
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
echo "# configure local bash environment"
. ${script_dir}/set-env.sh 

# Command line argument for specifying a Configuration https://www.eclipse.org/forums/index.php/t/1086000/
if [[ ${oomph} -eq 1 ]]; then
  if [[ -f ${oomph_exec} ]]; then
    # oomph installer with config file
    # delete empty logfiles  
    #find ${KLIBIO}/tool -size 0 -print -delete
    echo "# launching oomph in separate window ${config_url}"
    "${oomph_exec}" \
      ${config_url} \
      -vm "${java_bin}" \
      -vmargs \
      ${dev_vm_arg:-""} \
      -Dorg.eclipse.oomph.setup.donate=false \
      -Doomph.update.url=${oomph_update_url} \
      -Doomph.installer.update.url=${oomph_installer_update_url} \
      -Doomph.setup.installer.mode=advanced \
      -Doomph.redirection.setups=http://git.eclipse.org/c/oomph/org.eclipse.oomph.git/plain/setups/-\>${setup_url}/ \
      2> ${KLIBIO}/tool/${date}_oomph_err.log \
      1> ${KLIBIO}/tool/${date}_oomph_out.log \
      &
  else  
    echo "no oomph installation found inside ${oomph_exec} - re-install with -o/--oomph"
  fi
fi

if [[ ${eclipse} -eq 1 ]]; then
  eclipse_cmd=${eclipse_install}/eclipse/eclipse
  if [[ -f ${eclipse_cmd} ]]; then
      # MIND the DOT at beginning of line
      echo "# configure local bash environment (environment variables and proxy)"
      . ~/.klibio/set-env.sh 
      env | sort | grep -E 'arti|engine|^HOME|^JAVA'
      echo "# launching ${eclipse_cmd}"
      "${eclipse_cmd}" \
      {ecl_wrkspc} \
        -vm "${java_bin}" \
        > ${eclipse_install}/${date}_eclipse.log 2>&1 \
        &
    else
    echo "no eclipse installation found inside ${eclipse_cmd}"
  fi
fi

set +o nounset  # exit with error on unset variables
set +o errexit  # exit if any statement returns a non-true return value
set +o pipefail # exit if any pipe command is failing
