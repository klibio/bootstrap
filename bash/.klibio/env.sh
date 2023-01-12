#!/bin/bash
#
# identify and analyse the environment from the platform/OS running on
#

# general 
export branch=$(git rev-parse --abbrev-ref HEAD)

# export variable into 
if [ -v "AGENT_ID" ]; then
  echo "running inside workflow pipeline - hence set variables"
  echo "##vso[task.setvariable variable=BRANCH]${branch}"
fi

# OS specific environment variables

if [[ "$OSTYPE" == "msys" ]]; then
  export os=windows
  export jq=jq-win64.exe
  export eclInstaller=win64.zip
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  export os=mac
  export jq=jq-osx-amd64
  export java_home_suffix=/Contents/Home
  export eclInstaller=mac64.tar.gz
fi
if [[ "$OSTYPE" == "linux"* ]]; then
  export os=linux
  export jq=jq-linux64
  export eclInstaller=linux64.tar.gz
fi

echo "running on os $os"
