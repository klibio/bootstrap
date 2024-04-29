#!/bin/bash
#
# proof-of-performance execution
#
script_dir=$(dirname $(readlink -f $0))
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

# load lib functions when local execution
#branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null ) || branch=${branch:-main}
#lib_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/.klibio/klibio.sh
#$(curl -fsSLO ${lib_url})
#. klibio.sh

headline "start # install klibio extension from ${installer_url}"
installer_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install-klibio.sh
/bin/bash -c "$(curl -fsSLO ${installer_url})" bash -j -o -f
headline "finished # install klibio extension"

headline "start # launching proof-of-performance"
pop_script=~/.klibio/pop.sh
ls -la ${HOME}
if [ ! -f $pop_script ]; then 
  echo "failing curl install of $installer_url"
  exit 1
fi
/bin/bash $pop_script
headline "finished # proof-of-performance execution"
