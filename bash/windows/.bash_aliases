#
# alias file for bash
#

alias c='clear'

alias ls='ls --color=auto'
alias l='ls -la --color=auto'
alias ll='ls -la --color=auto'
alias l.='ls -d .* --color=auto'

alias ..='cd ../'

# avoid misspelllings
alias cd..='cd ..'

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# install colordiff package :)
alias diff='colordiff'

# handy short cuts #
alias h='history'
alias j='jobs -l'

# create a new set of commands
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# show open ports
alias ports='netstat -tulanp'
