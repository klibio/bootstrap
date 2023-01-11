#!/bin/bash
if [[ "$OSTYPE" == "msys" ]]; then
  export os=windows
  export jq=jq-win64.exe
  export eclInstaller=win64.zip
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  export os=mac
  export jq=jq-osx-amd64
<<<<<<< HEAD
  export java_home_suffix=/Contents/Home
=======
  export eclInstaller=mac64.tar.gz
>>>>>>> f7473c7... Feature/eclipse installer (#2)
fi
if [[ "$OSTYPE" == "linux"* ]]; then
  export os=linux
  export jq=jq-linux64
  export eclInstaller=linux64.tar.gz
fi

echo "running on os $os"
