#!/bin/bash
set -eou pipefail
IFS=$'\n' # Set IFS to newline to handle spaces in filenames

log() {
    echo
    echo "#############################################"
    echo "$1"
    echo "#############################################"
}

ssh_setup() {
    log "Setting up SSH access to remotehost"
    sudo ssh-keygen -t ed25519 -f ~/.ssh/id_rsa -N "" <<< y
    for host in $(cat hosts.txt); do
        sudo ssh-copy-id -i ~/.ssh/id_rsa.pub $host
        log "SSH access setup for $host"
    done
}

main() {
    ssh_setup
    log "Remote host setup complete"
}
main

