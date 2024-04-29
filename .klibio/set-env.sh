#!/bin/bash
#
# switch the java version in PATH and JAVA_HOME
#

# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi

set_env_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# load library
. ${set_env_dir}/klibio.sh
set-env
