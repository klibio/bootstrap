#!/bin/bash

# activate bash checks
set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

# load library
. /dev/stdin <<< "$(cat ~/.klibio/klibio.bash)"

if [[ "$#" == 0 ]]; then
  echo "$(cat <<-EOM
# please provide one or more of the following applications are available
-o|--ommph  oomph eclipse installer
EOM
)"
fi

# tool variables
oomph=0

for i in "$@"; do
  case $i in
    # tool parameter
    -o|--oomph)
      oomph=1
      ;;
    -o=*|--oomph=*)
      oomph_config="${i#*=}"
      oomph=1
      shift # past argument=value
      ;;
    # tool parameter
    --dev)
      dev_vm_arg="$(cat <<-EOM
-Duser.home=x:/oomph_delme \
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

# Command line argument for specifying a Configuration https://www.eclipse.org/forums/index.php/t/1086000/

if [[ ${oomph} -eq 1 ]]; then
  # minimal oomph version
  jvm=$(echo ${KLIBIO}/java/ee/JAVA11${java_home_suffix}/bin)
  oomph_exec=$(echo "${KLIBIO}/tool/eclipse-installer/${oomph_exec_suffix}")
  if [[ -z ${oomph_config+x} ]]; then
    echo "# launching oomph in separate window"
    "${oomph_exec}" \
      -vm "${jvm}" \
      -vmargs \
      -Doomph.setup.installer.mode=advanced \
        ${dev_vm_arg:-""} &
   else
    config_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/oomph/config/${oomph_config/\//_}.setup
    echo "# launching oomph in separate window with config ${config_url}"
   "${oomph_exec}" \
      -vm "${jvm}" \
      ${config_url} \
      -vmargs \
      -Doomph.setup.installer.mode=advanced \
        ${dev_vm_arg:-""} &
   fi
fi

set +o nounset  # exit with error on unset variables
set +o errexit  # exit if any statement returns a non-true return value
set +o pipefail # exit if any pipe command is failing
