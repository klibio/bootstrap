#!/bin/bash
set -Eeuo pipefail
scriptDir=$(cd "$(dirname "$0")" && pwd)

if [[ "$OSTYPE" == "msys" ]]; then
  os=windows
  jq=jq-win64.exe
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  os=mac
  jq=jq-osx-amd64
fi
if [[ "$OSTYPE" == "linux"* ]]; then
  os=linux
  jq=jq-linux64
fi
