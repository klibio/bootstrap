#!/bin/bash
#
# proof-of-performance execution
#

# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

# activate debug
if [[ ! -z ${DEBUG+x} ]]; then 
    echo "$(cat <<-EOM
###########################################################
#
# DEBUG
#
###########################################################
EOM
)"
    set -o xtrace
    export activate_debug=-x
    echo "uname=$(uname -a)"
    echo "arch=$(arch)"
    echo "# DEBUG env start"
    env | sort
    echo "# DEBUG env end"
fi

branch=$(git rev-parse --abbrev-ref HEAD) && branch=${branch:-main}
lib_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/klibio.bash
echo "# sourcing klibio lib - ${lib_url}"
. /dev/stdin <<< "$(curl -fsSL ${lib_url})"

headline "proof-of-performance execution - started"

installer_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install-klibio.sh
headline "# execute users command - ${installer_url}"
curl -fsSLO ${installer_url}
bash ${activate_debug:-} ./install-klibio.sh -b=${branch} -f -j -o
rm install-klibio.sh

headline "# launch pop inside new bash (containing installed .bashrc) "
ls -la ${HOME}
cat ${HOME}/.bashrc
bash ${activate_debug:-} ${KLIBIO}/pop.sh

headline "proof-of-performance execution - finished"
