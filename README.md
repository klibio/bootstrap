# bootstrap developer machine (bndtools, eclipse, java)

![proof-of-performance build](https://github.com/klibio/bootstrap/actions/workflows/pop.yml/badge.svg)

quick and easy setup and configuration of 

* bash (aliases, prompt)
* java LTS releases [8, 11, 17] e.g. `set-java.sh 11`
* eclipse/oomph installer 

on supported os [windows,mac,linux] and arch [arm64,x64]

# direct installation
execute the following script for installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/main/install-klibio.sh)" bash -j -o
```

# parameters
```bash
-b=<branch_name>    install from a specific branch
-j                  install java LTS versions
-o                  install eclipse installer / oomph
-f                  force overwrite existing files
```

# principles applied on 
* minimal host changes (only additions in `.bashrc` scripts and `PATH` variable)
* idempotent execution (can be consecutively executed give same result)

# glossary

pop - proof-of-performance is used as term instead of test - we want to assure spec'd functionality
