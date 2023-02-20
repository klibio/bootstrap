# Gitlab

```bash
export git_pat_token=<gitlab-pat-token>

export gitlab_server=gitlab.klib.io
# Gitlab group `dev` with id=11
export gitlab_groupid=11

# ToDo
curl -H "PRIVATE-TOKEN: ${git_pat_token}"\
      "https://${gitlab_server}/api/v4/groups?search=dev" \
      | jq -r '.[] | .id')

# list all projects inside a provided group id
curl --header "PRIVATE-TOKEN: ${git_pat_token}" \
    "https://${gitlab_server}/api/v4/groups/${gitlab_groupid}/projects" \
    | jq -r '.[] | .name | gsub("[\\n\\t]"; "")' | sort >  gitlab_response.json
```