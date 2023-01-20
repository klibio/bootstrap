#!/bin/bash
#
# proof-of-performance execution
#

# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

# activate debug
if [[ -z ${DEBUG+x} ]]; then 
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

echo "# load klibio library"
branch=$(git rev-parse --abbrev-ref HEAD) && branch=${branch:-main}
. /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/klibio.bash)"

headline "proof-of-performance execution - started"

headline "# execute users command - install-klibio.sh"
curl -fsSLO https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install-klibio.sh
bash ${activate_debug} ./install-klibio.sh -b=${branch} -f -j -o
rm install-klibio.sh
ls -la ${KLIBIO}/

padout "# launch a new bash with the actual test (sourcing the installed .bashrc) "
bash ${activate_debug} ${KLIBIO}/pop.sh

headline "proof-of-performance execution - finished"
