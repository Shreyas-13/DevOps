## This is a document on setting up a apache web server

#!/bin/bash
set -eou pipefail
PACKAGE="httpd wget unzip"

log() {
    echo "#############################################"
    echo "$1"
    echo "#############################################"
}

install_packages() {
    log "Installing packages: $PACKAGE"
    sudo dnf update -y
    sudo dnf install httpd wget unzip -y
}

setup_webserver() {
    log "Setting up web server"
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld
}

download_webfiles() {
    log "Downloading web files"
    wget -O /tmp/webfiles.zip "https://www.tooplate.com/zip-templates/2153_fireworks_composer.zip"
    unzip /tmp/webfiles.zip -d /tmp/
    sudo cp /tmp/2153_fireworks_composer/* /var/www/html/
    sudo chown apache:apache /var/www/html/* -R
    log "Web files downloaded extracted and moved"
    sudo systemctl restart httpd
}

main() {
    #log "$(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
    for host in $(cat hosts.txt); do
        ssh $host "$(typeset -f); install_packages; setup_webserver; download_webfiles"
    done
    log "Web server setup complete on remotehost"
}
main
