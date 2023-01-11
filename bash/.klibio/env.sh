#!/bin/bash
if [[ "$OSTYPE" == "msys" ]]; then
  export os=windows
  export jq=jq-win64.exe
  export java_home_suffix=
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  export os=mac
  export jq=jq-osx-amd64
  export java_home_suffix=/Contents/Home
fi
if [[ "$OSTYPE" == "linux"* ]]; then
  export os=linux
  export jq=jq-linux64
  export java_home_suffix=
fi

echo "running on os $os"
