#!/bin/bash
scriptDir=$(cd "$(dirname "$0")" && pwd)

file=klibio.tar.gz
pushd $scriptDir/bash >/dev/null 2>&1
rm $file >/dev/null 2>&1
tar -zvcf $scriptDir/$file .klibio
popd >/dev/null 2>&1
