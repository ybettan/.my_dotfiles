#!/bin/bash

links=()
failedLinks=()

links+=("bashrc")
links+=("bash_profile")
links+=("aliases")
links+=("vimrc")
links+=("tmux.conf")
links+=("launchers")
links+=("gitconfig")
links+=("ssh.config")
[[ $os == "Darwin" ]] && links+=("alacritty.yml")

for l in ${links[*]}; do

    # ssh.config need a special repo in ~
    if [[ $l == "ssh.config" ]]; then
        if ! [[ -d ~/.ssh ]]; then
            mkdir ~/.ssh
        fi
        ln -s -f $(pwd)/dotfiles/$l ~/.ssh/config && echo "copy .$l..." || err=$?
    else
        ln -s -f $(pwd)/dotfiles/$l ~/.$l && echo "copy .$l..." || err=$?
    fi
done

# without this sometimes ssh command doesn't work
chmod 600 ~/.ssh/config || err=$?

# macOS terminal source .bash_profile and linux terminal source .bashrc, so
# this solution covers both cases since .bash_profile source .bashrc
if [ -e ~/.bash_profile ] ; then
    echo source ~/.bash_profile...
    source ~/.bash_profile
fi
