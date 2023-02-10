# user environment variables used on windows for klibio library

"configure environment variables in user scope"
[System.Environment]::SetEnvironmentVariable('HOME',$env:USERPROFILE, 'User')
[System.Environment]::SetEnvironmentVariable('GIT_ASKPASS',$env:ProgramFiles+'\Git\mingw64\libexec\git-core\git-askpass.exe', 'User')
[System.Environment]::SetEnvironmentVariable('GIT_SSH',$env:ProgramFiles+'\Git\usr\bin\ssh.exe', 'User')

"list existing environment variables"
gci env:* | sort-object name

"press any key to continue"
[Console]::ReadKey()