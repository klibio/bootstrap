#!/usr/bin/env bash

export KLIBIO=$(echo ~/.klibio)

# java settings
if [ -f ${KLIBIO}/set-java.sh ]
then
  # append klibio tools folder to path
  export PATH=${PATH}:${KLIBIO}
  # configure default java to version 17
  set-java.sh 17
fi

# define bash prompt
if [[ $SHELL == "/bin/bash" ]]
then 
  PS1="\D{%Y%m%d-%H%M%S} \u@\H:\w jobs=\j\n$ "
fi

# load aliases
if [ -f ~/.profile ]
then
  . ~/.profile
fi
