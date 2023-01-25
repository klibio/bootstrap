#!/bin/bash
#
# proof-of-performance execution
#
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
  export activate_debug=-x
  echo "uname=$(uname -a)"
  echo "arch=$(arch)"
  echo "# DEBUG env start"
  env | sort
  echo "# DEBUG env end"
fi
# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null ) || branch=${branch:-main}
lib_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/bash/.klibio/klibio.sh
$(curl -fsSLO ${lib_url})
. klibio.sh

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
