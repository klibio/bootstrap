#!/bin/bash

# activate bash checks
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

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
    # tool parameter
    --dev)
      set -o xtrace
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

if (($oomph)); then
  echo "# launching in a separate window oomph eclipse installer"
  #config_url=http://git.eclipse.org/c/emf/org.eclipse.emf.git/plain/releng/org.eclipse.emf.releng/EMFDevelopmentEnvironmentConfiguration.setup
  #config_url=file:/X:/git/github.com/klibio/bootstrap/bash/.klibio/oomph/config/KlibioBoostrapConfiguration.setup
  config_url=https://raw.githubusercontent.com/klibio/bootstrap/feature/oomph-configs/bash/.klibio/oomph/config/KlibioBoostrapConfiguration.setup
  jvm=$(echo ~/.klibio/java/ee/JAVA11/bin)
  ~/.klibio/tool/eclipse-installer/eclipse-inst.exe \
    -vm ${jvm} \
    ${config_url} \
    -vmargs \
      ${dev_vm_arg:-""} &
fi

set +o nounset  # exit with error on unset variables
set +o errexit  # exit if any statement returns a non-true return value
set +o pipefail # exit if any pipe command is failing
