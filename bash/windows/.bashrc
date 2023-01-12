# additional path entries can be added here with : as separator
#PATH=${PATH}:xyz

export KLIBIO=$(echo ~/.klibio)

# java settings
if [ -f $KLIBIO/set-java.sh ]
then
  # configure default java to version 17
  $KLIBIO/set-java.sh 17
  # switching java version alias
  alias set-java='. $KLIBIO/set-java.sh'
fi

# define prompt
PS1="\D{%Y%m%d-%H%M%S} \u@\H:\w jobs=\j\n$ "

if [ -f $HOME/.bash_aliases ]
then
  . $HOME/.bash_aliases
fi
