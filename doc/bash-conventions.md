# bash-coding conventions

## Bash best practices

Here you can find a series of tips when developing a Bash script:

- Start your scripts with the proper shebang: `#!/bin/bash`.
- Start each file with a description of its contents.
- Use built-in options `set -o OPTION`:
    - **errexit**: make your script exit when a command fails. Add `|| true` to allow a command to fail.
    - **nounset**: make your script exit when using undeclared variables.
    - **pipefail**: sets the exit code of a pipeline to that of the rightmost command to exit with a non-zero status, or to zero if all commands of the pipeline exit successfully.
    - **xtrace**: only for debugging.
- Create a main function for scripts long enough to contain at least one other function.
- Use `local` when declaring variables in functions, unless there is reason to use `declare`.
- Use `readonly` when defining "read only" constants.
- Use `:-` for variables that could be undeclared.
- Naming conventions:
    - Only use uppercase on constants or when a variable is exported to the environment.
    - Use underscore `_` instead of `-` to separate words. Do not use _camelCase_.
    - Do not start variable names with special characters or numbers.
- Use `. xxx.sh` instead of `source xxx.sh`.
- Use `$()` over backticks.
- Use `${var}` instead of `$var` when concatenating strings.
- Double quote variables, no naked `$` signs.
- Use `my_func() { ... }` instead of `function my_func { ... }`.
- Use `&&` and `||` for simple conditionals.
- Put `then;`, `do;`, etc. on the same line.
- Use `[[` instead of `[`.
- Prefer absolute paths.
- Avoiding temporary files. Use process substitution (`<()`) to transform commands output into sth that can be used as a filename:

    ~~~bash
    # Note that if any of the wget fails, and the diff succeed, this
    # statement will success regarding of built-in options!
    diff <(wget -O - url1) <(wget -O - url2)
    ~~~

- Warnings and errors should go to _STDERR_.
- Use `bash -x myscript.sh` for debugging.

> Note: You can use [ShellCheck](https://www.shellcheck.net) to ensure your bash syntax does not contain any warning/error. Linters will be included on repositories to ensure every commit passes a series of checks.

# Hints 

## mind interactive and non-interactive script execution

init scripts (like .bashrc) are not executed on non-interactive executions
