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
-o=<git-server>/<org>|--ommph=<git-server>/<org>  create oomph projects and configs for git-server and org projects
-f|--force  overwrite existing files
EOM
)"
exit 0
fi

echo "# create derived objects"

# process step variables (all MUST be false and only activated by user option)
exec_bash_archive=false
exec_oomph_setups=false
git_org=klibio
git_host="https://github.com"
host_platform=github
overwrite=false

for i in "$@"; do
  case $i in
    # tool parameter
    -b|--bash)
      exec_bash_archive=true
      ;;
    -o=*|--oomph=*)
      exec_oomph_setups=true

      # use everything after the last slash as org
      git_org=$(echo ${i#*=} | sed 's|.*/||')

      # use everything before the last slash as host
      git_host=$(echo ${i#*=} | sed -e 's|^[^/]*//||' -e 's|/.*$||')
      shift # past argument=value      
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
    if  [[ -f "$script_dir/$file" ]]; then 
      rm $script_dir/$file >/dev/null 2>&1; 
    fi
    tar -zvcf $script_dir/$file .klibio/
fi

if [[ ${exec_oomph_setups} == "true"  ]]; then
  echo -e "#\n# retrieve projects for a given ${git_host} organisation ${git_org}\n#\n"
  
  if [[ ! -n "$git_pat_token" ]]; then
    echo "mandatory environment variable 'git_pat_token' for git $git_org is missing"
    exit 1
  fi

  url=https://api.${git_host}/orgs/${git_org}/repos
  file_response=gh_repos_response.json
  
  echo "accessing ${git_host} for organization ${git_org}"
  if [[ ${git_host} == *"github"* ]]; then
    url=https://api.${git_host}/orgs/${git_org}/repos
    curl \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${git_pat_token}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      ${url} \
      | jq -r '.[] | .name | gsub("[\\n\\t]"; "")' | sort > ${file_response}
  fi

  # destinguishing between github and gitlab because of different api url structure
  if [[ ${git_host} == *"gitlab"* ]]; then
    group_url=https://${git_host}/api/v4/groups?search=${git_org}
    host_platform=gitlab
    gitlab_groupid=$(
      curl -H "PRIVATE-TOKEN: ${git_pat_token}"\
      ${group_url} \
      | jq -r '.[] | .id')

    url=https://${git_host}/api/v4/groups/${gitlab_groupid}/projects

    curl -H "PRIVATE-TOKEN: ${git_pat_token}" \
      ${url} \
      | jq -r '.[] | .name | gsub("[\\n\\t]"; "")' | sort >  ${file_response}
  fi

# shortcut for processing only specific projects
#cat >${file_response} <<-EOL
#bootstrap
#EOL

  for row in $(cat ${file_response}); do
      repo=$(echo ${row})
      echo -e "#\n# processing repo ${repo} \n#\n"

      project_dir=${script_dir}/oomph/projects
      mkdir -p ${project_dir}
      file=${project_dir}/prj_${git_host}_${git_org}_${repo}.setup

      if  [[ -e ${file} ]]; then
            echo "## skip existing project setup file klibio_${repo}.setup"
      else
        echo "## create project setup file klibio_${repo}.setup"
        while read -r line; do
          echo $(echo "${line//__REPO__/${repo}}") >> ${file}
          if [ -f ${file} ]; then
              sed -i "s/__ORG__/${git_org}/g" $file
          fi
        done < ./oomph/template/template_${git_host}_prj.setup
      fi

      config_dir=${script_dir}/oomph/config
      mkdir -p ${config_dir}
      file=${config_dir}/cfg_${git_host}_${git_org}_${repo}.setup
      if  [[ -e ${file} ]]; then
          echo "## skip existing project config file cfg_klibio_${repo}.setup"
      else
        echo "## create project config file cfg_klibio_${repo}.setup"
        while read -r line; do
          echo $(echo "${line//__REPO__/${repo}}") >> ${file}
          if [ -f ${file} ]; then
              sed -i "s/__ORG__/${git_org}/g" $file
          fi
        done < ./oomph/template/template_${git_host}_cfg.setup
      fi
  done
  rm ${file_response}
fi