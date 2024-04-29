# powershell script for configuring environment variables inside USER scope

"configure user scope environment variables used on windows for klibio library"

"configure user home to avoid enterprise profile usage"
[System.Environment]::SetEnvironmentVariable('HOME',$env:USERPROFILE, 'User')

"configure windows OpenSSH to be used for git"
[System.Environment]::SetEnvironmentVariable('GIT_SSH',$env:SystemRoot+'\System32\OpenSSH\ssh.exe', 'User')
[System.Environment]::SetEnvironmentVariable('GIT_ASKPASS','', 'User')

#"configure git vars to self-contained apps"
#[System.Environment]::SetEnvironmentVariable('GIT_ASKPASS',$env:ProgramFiles+'\Git\mingw64\libexec\git-core\git-askpass.exe', 'User')
#[System.Environment]::SetEnvironmentVariable('GIT_SSH',$env:ProgramFiles+'\Git\usr\bin\ssh.exe', 'User')

"list existing environment variables"
gci env:* | sort-object name

"press any key to continue"
[Console]::ReadKey()