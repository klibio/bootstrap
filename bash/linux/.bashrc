# additional path entries can be added here with : as separator
#PATH=${PATH}:xyz

export KLIBIO=$(echo ~/.klibio)

alias c='clear'

alias ls='ls --color=auto'
alias l='ls -la --color=auto'
alias ll='ls -la --color=auto'
alias l.='ls -d .* --color=auto'

# avoid misspelllings
alias cd..='cd ..'

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# install  colordiff package :)
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

PS1="\D{%Y%m%d-%H%M%S} \u@\H:\w jobs=\j\n$"

# switching between java versions
alias setJava='source ${KLIBIO}/setJava.sh'

# configure default java to version 17
setJava 17
