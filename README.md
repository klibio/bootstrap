# bootstrap your bndtools, eclipse, java developer machine

![proof-of-performance build](https://github.com/klibio/bootstrap/actions/workflows/pop.yml/badge.svg)

quick and easy setup of 

* bash
* java LTS 
* eclipse/oomph installer 

on supported os[windows,mac,linux] and arch[arm,arm64,x86,x64]

# direct installation
execute the following script for installation on a machine inside a bash
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/main/install.sh)"
```

# local execution with parameters
```bash

curl -fsSL https://raw.githubusercontent.com/klibio/bootstrap/${branch}/install.sh > ./klibio_setup.sh
chmod u+x ./klibio_setup.sh
bash ./klibio_setup.sh -b=${branch} -o
rm klibio_setup.sh

with optional parameters

-b=<branch_name>    install from a specific branch
-o                  force overwrite existing files 
```
