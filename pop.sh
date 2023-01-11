#!/bin/bash
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

branch=${1:-main}

echo "# INSTALL"
curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install.sh > ./klibio_setup.sh
chmod u+x ./klibio_setup.sh
# for argument passing see https://unix.stackexchange.com/a/144519/116365
bash ./klibio_setup.sh -b=${branch} -o
rm klibio_setup.sh

echo "# launch a new bash with the actual test (sourcing the installed .bashrc) "
bash ~/.klibio/testEnv.sh
