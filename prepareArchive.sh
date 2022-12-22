#!/bin/bash
set -Eeuo pipefail
scriptDir=$(cd "$(dirname "$0")" && pwd)

pushd $scriptDir/bash > /dev/null
tar -zvcf $scriptDir/klibio.tar.gz .klibio
popd > /dev/null
