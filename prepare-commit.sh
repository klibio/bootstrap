#!/bin/bash
#
# script for creating derived resources before a commit
#
script_dir=$(dirname $(readlink -f $0))

# activate bash checks
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi
# activate bash checks
set -o nounset  # exit with error on unset variables
set -o errexit  # exit if any statement returns a non-true return value
set -o pipefail # exit if any pipe command is failing

if [[ "$#" == 0 ]]; then
  echo "$(cat <<-EOM
# please provide one or more options of the following options
-b|--bash   update the archive for the USERHOME <.klibio.tar.gz>
-o|--ommph  create oomph projects and configs for klibio projects
-f|--force  overwrite existing files
EOM
)"
exit 0
fi

echo "# create derived objects"

# process step variables (all MUST be false and only activated by user option)
exec_bash_archive=false
exec_oomph_setups=false
overwrite=false

for i in "$@"; do
  case $i in
    # tool parameter
    -b|--bash)
      exec_bash_archive=true
      ;;
    -o|--oomph)
      exec_oomph_setups=true
      ;;
    # for develoment purposes
    -f|--force)
      overwrite=true
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
    echo -e "#\n#  updating archive ${file} \n#\n"
    rm $script_dir/$file >/dev/null 2>&1
    pushd $script_dir/bash >/dev/null 2>&1
    tar -zvcf $script_dir/$file .klibio
    popd >/dev/null 2>&1
fi

if [[ ${exec_oomph_setups} == "true"  ]]; then
  # retrieve projects for a given github organisation
  org=klibio
  if [[ ! -n "$github_token" ]]; then
    echo "mandatory environment variable 'github_token' for GITHUB $org is missing"
    exit 1
  fi

  url=https://api.github.com/orgs/${org}/repos
  file_response=gh_repos_response.json
  curl \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${github_token}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      ${url} > ${file_response}
  
  for row in $(cat ${file_response} | jq -r '.[] | .name' | sort); do
      repo=$(echo ${row} | sed 's/\\n/\n/g')
      echo -e "#\n# processing repo ${repo} \n#\n"

      file=${script_dir}/oomph/projects/klibio_${repo}.setup
      if  [[ -e ${file} && ${overwrite} != "true" ]]; then
          echo "## skip existing project setup file klibio_${repo}.setup"
      else
          echo "## create project setup file klibio_${repo}.setup"
          while read -r line; do
          echo $(echo "${line//__REPO__/${repo}}") >> ${file}
          if [ -f ${file} ]; then
              sed -i "s/__ORG__/${org}/g" $file
          fi
          done < ./oomph/template/klibio_project_template.setup
      fi

      file=${script_dir}/oomph/config/klibio_${repo}.setup
      if  [[ -e ${file} && ${overwrite} != "true" ]]; then
          echo "## skip existing project config file klibio_${repo}.setup"
      else
          echo "## create project config file klibio_${repo}.setup"
          while read -r line; do
          echo $(echo "${line//__REPO__/${repo}}") >> ${file}
          if [ -f ${file} ]; then
              sed -i "s/__ORG__/${org}/g" $file
          fi
          done < ./oomph/template/klibio_config_template.setup
      fi
  done
  rm ${file_response}
fi