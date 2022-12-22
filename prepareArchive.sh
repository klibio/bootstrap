#!/bin/bash
set -Eeuo pipefail
scriptDir=$(cd "$(dirname "$0")" && pwd)

pushd $scriptDir/0_bash > /dev/null
tar -zvcf $scriptDir/klibio.tar.gz .klibio
popd > /dev/null
