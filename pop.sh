#!/bin/bash
set -Eeuo pipefail

branch=${1:-main}

echo "# INSTALL"
curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install.sh > ./klibio_setup.sh
chmod u+x ./klibio_setup.sh
# for argument passing see https://unix.stackexchange.com/a/144519/116365
bash ./klibio_setup.sh -b=${branch} -o
rm klibio_setup.sh

echo "# launch a new bash with the actual test (sourcing the installed .bashrc) "
bash -x ~/.klibio/testEnv.sh
