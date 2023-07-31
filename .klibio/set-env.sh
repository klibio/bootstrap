#!/bin/bash
#
# switch the java version in PATH and JAVA_HOME
#

# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi

# load library
. eclib.sh

global_props=~/.ec_global.properties
if [ -f ${global_props} ]; then
  . ${HOME}/.ecdev/prop2env.sh ${global_props}
else
    echo "please download and configure ${global_props}"
    echo "https://pages.git.i.mercedes-benz.com/cec/idefix/smaragd.html"
    return
fi

. ${HOME}/.ecdev/proxy.sh


