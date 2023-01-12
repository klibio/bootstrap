# 

export KLIBIO=$(echo ~/.klibio)

# java settings
if [ -f ${KLIBIO}/set-java.sh ]
then
  # configure default java to version 17
  ${KLIBIO}/set-java.sh 17
  # append klibio tools folder to path
  export PATH=${PATH}:${KLIBIO}
fi

# define prompt
PS1="\D{%Y%m%d-%H%M%S} \u@\H:\w jobs=\j\n$ "

# load aliases
if [ -f $HOME/.bash_aliases ]
then
  . $HOME/.bash_aliases
fi
