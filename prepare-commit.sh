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

function usage () {
  echo "$(cat <<-EOM
# please provide one or more options of the following options
-b|--bash   update the archive for the USERHOME <.klibio.tar.gz>
-o=<git-server>/<org>|--ommph=<git-server>/<org>  create oomph projects and configs for git-server and org projects
-f|--force  overwrite existing files
EOM
)"
}

if [[ "$#" == 0 ]]; then
exit 0
fi

echo "# create derived objects"

# process step variables (all MUST be false and only activated by user option)
exec_bash_archive=false
exec_oomph_setups=false
git_org=klibio
git_host="github.com"
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
      # input form example: https://github.com/klibio/
      # use fourth field with / as separator as orga
      git_org=$(echo ${i#*=} | cut -d '/' -f 4)

      # use third field with / as separator as host
      git_host=$(echo ${i#*=} | cut -d '/' -f 3)
      shift # past argument=value      
      ;;
    # for develoment purposes
    -f|--force)
      overwrite=true
      ;;
    # default for unknown parameter
    -*|--*)
      echo "unknow option $i provided"
      usage
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
    url=https://api.${git_host}/orgs/${git_org}/repos?per_page=1000
    curl \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${git_pat_token}" \
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
      file=prj_${git_host}_${git_org}_${repo}.setup

      if  [[ -e ${project_dir}/${file} ]]; then
            echo "## skip existing project setup file ${file}"
      else
        echo "## create project setup file ${file}"
        while read -r line; do
          echo $(echo "${line//__REPO__/${repo}}") >> ${project_dir}/${file}
        done < ./oomph/template/template_${git_host}_prj.setup
        if [ -f ${project_dir}/${file} ]; then
          sed -i "s/__ORG__/${git_org}/g" ${project_dir}/$file
        fi
      fi

      config_dir=${script_dir}/oomph/config
      mkdir -p ${config_dir}
      file=cfg_${git_host}_${git_org}_${repo}.setup
      if  [[ -e ${config_dir}/${file} ]]; then
          echo "## skip existing project config file ${file}"
      else
        echo "## create project config file ${file}"
        while read -r line; do
          echo $(echo "${line//__REPO__/${repo}}") >> ${config_dir}/${file}
        done < ./oomph/template/template_${git_host}_cfg.setup
        if [ -f ${config_dir}/${file} ]; then
          sed -i "s/__ORG__/${git_org}/g" ${config_dir}/$file
          sed -i "s/__HOST__/${git_host}/g" ${config_dir}/$file
        fi
      fi
  done
  rm ${file_response}
fi