# org/project development setup

## Organisation/Project Configuration

0. pre-requisites
    * os: win, mac, linux
    * arch: x64, arm64
    * git (with bash)
    * curl
    * docker or remote machine with docker

1. **one-time configurations** config inside directory `win32: %USERHOME%` / `mac,*nix: $HOME`

    * pre-requisite on Windows OS - environment variable in USER scope `HOME=%USERPROFILE%`

    * Git configuration
        * template for [`~/.gitconfig`](../dev_config/.gitconfig)
        * ssh-key configuration
            * [GitHub/Github Enterprise](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#platform-windows)
            * [GitLab](https://docs.gitlab.com/ee/user/ssh.html)
        * GPG key for commit signature verification
            * [Generating a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)

    * template for [`~/.ssh/config`](../dev_config/.ssh/config)
    
    * `.cfg-org/user.properties`
        * user credentials
        * server configurations (git,artifactory,docker registry)
        * local development root directory for derived `<root>/wrk`, `<root>/result`
        * optional settings
            * proxy settings e.g. for enterprise settings
                environment variable `http_proxy`, `https_proxy`
            * gradle/java e.g. `org.gradle.jvmargs`
    

2. checkout repo            requires git

2. build with docker        requires docker, wsl2 and docker config e.g. proxy
    1. pull deps - store and re-used for local development setup as well
    2. build execution

3. develop ready

# suggested implementation

```md
# filename          -> purpose
0_configure.sh      -> configure the env based on version.properties
1_pull_dpes.sh      -> pull all dependencies
2_docker_build.sh   -> execute docker build
versions.properties -> all artifacts and versions
```

# important files/directories for backup

```md
# folders
~/.ssh/             -> containing ssh keys
~/.gnupg/           -> containing GPG keys

# files
~/.gitconfig        -> git configuration (parts can be host/os specific)
~/.eclipse/org.eclipse.equinox.security/secure_storage -> eclipse password storage
```

# W-I-P

# include pre-requisites into repos

## host for building

* artifactory
* git (including bash)
* docker
    * optional [portainer](https://docs.portainer.io/v/ce-2.11/start/install/server/docker/wsl) (as Container management frontent)

### host for development

* all from [building](#host-for-building) and additionally

* curl (self-contained cli tool for network access)

* java
* gradle (build automation tool, dep to java)

* idefix (Java/Eclipse IDE, dep to java)
    * Eclipse JustJ - java 
    * bnd - osgi development tooling
    * checkstyle - qa 

* optional vscode (fast and simple editor) 
    * optional docker extension