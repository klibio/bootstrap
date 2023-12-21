#!/bin/bash
#
# delete all idefix bootstrap directories

if [[ ! -z ${idefix_root+x} ]]; then
    idefix_root=${idefix_root}
else
    idefix_root=
fi

cat << 'EOF'
#################
### ATTENTION ###
#################

continuing will DELETE the following folders on your machine

~/.ecdev
~/.eclipse
~/.p2 
~/.m2
${idefix_root}


EOF
read -p "Do you really want to continue (y/n)? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n\nplease be patient this can take a while"
    rm -rf ~/.ecdev \
        ~/.eclipse \
        ~/.m2 \
        ~/.p2 \
        ${idefix_root}

    echo "deletion completed"
else
    echo "aborted"
fi