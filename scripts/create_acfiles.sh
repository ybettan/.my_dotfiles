#!/bin/bash

links=()
failedLinks=()

links+=("ssh")

for l in $@; do
    ln -s -f $(pwd)/acfiles/$l /usr/local/etc/bash_completion.d/$l \
        && echo "copy /usr/local/etc/bash_completion.d/$l..." \
        || err=$?
done

