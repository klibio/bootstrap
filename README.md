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

launch oomph with `start-klib.io -o`

launch oomph with a specific repo configuration `start-klib.io -o=<org>/<repo>`
```bash
$ start-klibio.sh -o=klibio/bootstrap
# launching oomph in separate window with config https://raw.githubusercontent.com/klibio/bootstrap/feature/x/oomph/config/cfg_klibio_bootstrap.setup
```
Opens a oomph gui installer pre-selecting the product and the project.
Provide the Installation folder name and press `Next >` and then `Finish` to get the Eclipse IDE installed with the repository checked out and imported. 
Your are ready to code ...

## implementation 
* minimal host changes
    * additions in `~/.bashrc` ( or `~/.zshrc` on OSX )
    * local folder `~/.klibio`
* idempotent execution

## glossary

pop - proof-of-performance is used as term instead of test - we want to assure spec'd functionality

### installation parameters
```bash
-b=<branch_name>    install from a specific branch
-j                  install java LTS versions
-o                  install eclipse installer / oomph
-u                  unsecure - allow self-signed certificates
-f                  force overwrite existing files
```

* [FAQ](doc/FAQ.md)
* [LICENSE](LICENSE)