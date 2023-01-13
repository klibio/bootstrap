# bootstrap your bndtools, eclipse, java developer machine

![proof-of-performance build](https://github.com/klibio/bootstrap/actions/workflows/pop.yml/badge.svg)

quick and easy setup of 

* bash (aliases, prompt)
* java LTS [8, 11, 17] e.g. `set-java 11`
* eclipse/oomph installer 

on supported os[windows,mac,linux] and arch[arm,arm64,x86,x64]

underlying principles are
* minimal host changes (only additions in `.bashrc` scripts and `PATH` variable)
* idempotent execution (can be consecutively executed give same result)

# direct installation
execute the following script for installation on a machine inside a bash
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/main/install-klibio.sh)"
```

# local execution with parameters
```bash

curl -fsSLO https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install-klibio.sh
chmod u+x ./install-klibio.sh
bash ./install-klibio.sh -b=${branch} -o
rm install-klibio.sh

with optional parameters

-b=<branch_name>    install from a specific branch
-o                  force overwrite existing files 
```

# glossary

pop - proof-of-performance is used as term instead of test - we want to assure spec'd functionality
