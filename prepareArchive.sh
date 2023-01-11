#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)

file=.klibio.tar.gz
pushd $script_dir/bash >/dev/null 2>&1
rm $file >/dev/null 2>&1
tar -zvcf $script_dir/$file .klibio
popd >/dev/null 2>&1
