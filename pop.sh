#!/bin/bash
#
# proof-of-performance execution
#

# activate bash checks
#set -o xtrace   # activate debug
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

echo "# load klibio library"
branch=$(git rev-parse --abbrev-ref HEAD)
#. /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/lib.bash)"
. /dev/stdin <<< "$(cat bash/.klibio/lib.bash)"

echo "# github env"
env | sort

headline "proof-of-performance execution"

padout "# execute users bash INSTALL command"
curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install.sh > ./klibio_setup.sh
chmod u+x ./klibio_setup.sh
bash ./klibio_setup.sh -b=${branch} -o
rm klibio_setup.sh

padout "# launch a new bash with the actual test (sourcing the installed .bashrc) "
bash ~/.klibio/testEnv.sh
