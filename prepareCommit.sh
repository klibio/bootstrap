#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)

file=.klibio.tar.gz
pushd $script_dir/bash >/dev/null 2>&1
rm $file >/dev/null 2>&1
tar -zvcf $script_dir/$file .klibio
popd >/dev/null 2>&1


# get all projects for a given github organisation
url=https://api.github.com/orgs/${org}/repos
curl \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${github_token}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    ${url} > resp.json
for row in $(cat resp.json | jq ".[] | .name"); do
    echo ${row}
    # here create setup files for each github repo FROM TEMPLATE
done
rm resp.json