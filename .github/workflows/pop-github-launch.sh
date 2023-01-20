#!/bin/bash
#
# proof-of-performance execution
#

# activate debug
if [[ -z ${DEBUG+x} ]]; then set -o xtrace; fi

# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

echo "# DEBUG start"
echo "uname=$(uname -a)"
echo "arch=$(arch)"
env | sort
echo "# DEBUG end"

echo "# load klibio library"
branch=$(git rev-parse --abbrev-ref HEAD) && branch=${branch:-main}
. /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/klibio.bash)"

headline "proof-of-performance execution - started"

headline "# execute users command - install-klibio.sh"
curl -fsSLO https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install-klibio.sh
chmod u+x ./install-klibio.sh
bash ./install-klibio.sh -b=${branch} -f -j
rm install-klibio.sh

padout "# launch a new bash with the actual test (sourcing the installed .bashrc) "
bash ~/.klibio/pop.sh

headline "proof-of-performance execution - finished"
