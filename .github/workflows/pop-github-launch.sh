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
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null ) || branch=${branch:-main}
echo "# running on branch $branch"

# load lib functions when local execution
#lib_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/.klibio/klibio.sh
#$(curl -fsSLO ${lib_url})
#. klibio.sh

installer_url=https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install-klibio.sh
echo -e "#\n# install klibio bootstrap from ${installer_url}\n#\n"
which bash
/bin/bash -c "$(curl -fsSL $installer_url)" bash -j -o -e -b=${branch}
echo -e "#\n# install klibio bootstrap finished\n#\n"

echo -e "#\n# start # launching proof-of-performance\n#\n"
env | grep HOME
pop_script=${HOME}/.klibio/pop.sh
if [ ! -f $pop_script ]; then 
  echo "failing curl install of $installer_url"
  exit 1
fi
/bin/bash -x $pop_script
echo -e "#\n# finished # proof-of-performance execution\n#\n"
