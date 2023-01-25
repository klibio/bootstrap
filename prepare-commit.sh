#!/bin/bash
#
# script for creating derived resources before a commit
#
script_dir=$(dirname $(readlink -e $BASH_SOURCE))
# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

echo "# create derived objects"

# tool variables
exec_bash_archive=true
exec_oomph_setups=false

for i in "$@"; do
  case $i in
    # tool parameter
    -b|--bash)
      exec_bash_archive=true
      ;;
    -o|--oomph)
      exec_oomph_setups=true
      ;;
    # default for unknown parameter
    -*|--*)
      echo "unknow option $i provided"
      exit 1
      ;;
    *)
      ;;
  esac
done

if [[ ${exec_bash_archive} == "true"  ]]; then
    file=.klibio.tar.gz
    pushd $script_dir/bash >/dev/null 2>&1
    rm $file >/dev/null 2>&1
    tar -zvcf $script_dir/$file .klibio
    popd >/dev/null 2>&1
fi

if [[ ${exec_oomph_setups} == "true"  ]]; then
  # get all projects for a given github organisation
  url=https://api.github.com/orgs/${org}/repos
  curl \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${github_token}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      ${url} > resp.json
  
  for row in $(cat resp.json | jq -r '.[] | .name'); do
      echo -e "#\n# creating project file for ${row} \n#\n"
      # here create setup files for each github repo FROM TEMPLATE
      repo=$(echo ${row} | sed 's/\\n/\n/g')
      file=./oomph/projects/klibio_${repo}.setup
      while read -r line; do
      echo $(echo "${line//__REPO__/${repo}}") >> ${file}
      if [ -f ${file} ]; then
          sed -i "s/__ORG__/${org}/g" $file
      fi
      done < ./oomph/projects/klibio_template.setup
  done
  rm resp.json
fi