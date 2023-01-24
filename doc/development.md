# development

describes the development of this project

## Trigger installation locally without any scripts from github repo

```bash
cd <repo_root>

# launch for local development
export KLIBIO=; ./install-klibio.sh --dev -j -o

# launch local development with bash debugging active
export KLIBIO=; export debug=true; ./install-klibio.sh --dev -j -o
```

Installation will take place inside `HOME` folder in the repo.

## bash

Please mind the [`bash-conventions.md`](bash-conventions.md) for modifying `*.sh|*.bash` files.

## oomph models

Eclipse Modeling with oomph tooling

## evaluation inside devel

```bash
pushd bash/devel; ./eval-sourcing.sh arg1 arg2 arg3; popd
```
