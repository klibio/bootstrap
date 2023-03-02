# Git on windows

## Windows 10

env vars for OS
```powershell
[System.Environment]::SetEnvironmentVariable('GIT_ASKPASS',$env:ProgramFiles+'\Git\mingw64\libexec\git-core\git-askpass.exe', 'User')
[System.Environment]::SetEnvironmentVariable('GIT_SSH',$env:ProgramFiles+'\Git\usr\bin\ssh.exe', 'User')
```


```~/.gitconfig
[core]
  sshcommand = 'C:/Windows/System32/OpenSSH/ssh.exe'
```

```bash

# create key
ssh-keygen -t ed25519 -C "user@domain.com" -f id_ed25519_gitlab.klib.io

# enter passphrase


# 
eval "$(ssh-agent -s)"
```

C:\Windows\System32\OpenSSH

``` bash
# error when ssh not correctly configured
$ git clone git@gitlab.klib.io:dev/osgi-demo.git
Cloning into 'osgi-demo'...
CreateProcessW failed error:193
ssh_askpass: posix_spawnp: Unknown error
git@gitlab.klib.io: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

## Useful

```bash
# list all git configs and where they are coming from
git config --list --show-origin
```

[Generating a new SSH key and adding it to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)


https://gist.github.com/jherax/979d052ad5759845028e6742d4e2343b
