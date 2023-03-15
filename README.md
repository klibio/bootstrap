# bootstrap developer machine (bndtools, eclipse, java)

![proof-of-performance build](https://github.com/klibio/bootstrap/actions/workflows/pop.yml/badge.svg)

quick and easy setup and configuration of 

* java LTS releases [8, 11, 17] e.g. `set-java.sh 11`
* eclipse/oomph installer 

on supported os [windows,mac,linux] and arch [arm64,x64] via bash extension

## installation
execute the following script for installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/main/install-klibio.sh)" bash -j -o
```
### installation parameters
```bash
-b=<branch_name>    install from a specific branch
-j                  install java LTS versions
-o                  install eclipse installer / oomph
-u                  unsecure curl - allow self-signed certificates
-f                  force overwrite existing files
```
## usage
### using specific Java LTS release

switch to a specific java version with `set-java.sh <8|11|17>`
```bash
$ set-java.sh 11
configure JAVA_HOME=/c/Users/peter/.klibio/java/ee/JAVA11
openjdk version "11.0.18" 2023-01-17
OpenJDK Runtime Environment Temurin-11.0.18+10 (build 11.0.18+10)
OpenJDK 64-Bit Server VM Temurin-11.0.18+10 (build 11.0.18+10, mixed mode)
```
### oomph / eclipse-installer

#### **option 1** - launch oomph / eclipse installer

```bash
$ start-klibio.sh -o
# launching oomph in separate window
```

#### **option 2** - launch oomph with a specific config

launch oomph with a specific config `start-klib.io -o=https://<host>/<org>/<repo>`
```bash
$ start-klibio.sh -o=https://github.com/klibio/bootstrap
# launching oomph in separate window with config https://raw.githubusercontent.com/klibio/bootstrap/feature/x/oomph/config/cfg_github.com_klibio_bootstrap.setup
```
1. Checks if there is an existing configuration file available.
2. Opens a oomph gui installer pre-selecting the product and the github project from klibio organisation.
3. Provide the Installation folder name and press `Next >` and then `Finish` to get the Eclipse IDE installed with the repository checked out and imported. 
4. Your are ready to code ...

## implementation 
* minimal host changes
    * additions in `~/.bashrc` ( or `~/.zshrc` on OSX )
    * local folder `~/.klibio`
* idempotent execution

# links

* [FAQ](doc/FAQ.md)
* [Glossary](doc/glossary.md)
* [LICENSE](LICENSE)