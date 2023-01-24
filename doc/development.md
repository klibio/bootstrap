# development

describes the development of this project

## Trigger installation locally without any scripts from github repo

```bash
cd <repo_root>

# launch for local development
./install-klibio.sh --dev -j -o

# launch local development with bash debugging active
export debug=true; ./install-klibio.sh --dev -j -o
```

Installation will take place inside `HOME` folder in the repo.

## bash

Please mind the [`bash-conventions.md`](bash-conventions.md) for modifying `*.sh|*.bash` files.

## oomph models

Eclipse Modeling with oomph tooling
