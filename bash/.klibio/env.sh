#!/bin/bash
set -Eeuo pipefail
scriptDir=$(cd "$(dirname "$0")" && pwd)

if [[ "$OSTYPE" == "msys" ]]; then
  export os=windows
  export jq=jq-win64.exe
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  export os=mac
  export jq=jq-osx-amd64
fi
if [[ "$OSTYPE" == "linux"* ]]; then
  export os=linux
  export jq=jq-linux64
fi

echo "running on os $os"
