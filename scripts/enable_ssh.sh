#!/bin/bash

# make sure all VMs are accessible via SSH
if [[ $bot == "non" && $os == "Linux" ]]; then
    systemctl restart sshd || err=$?
    systemctl enable sshd || err=$?
fi
