#!/bin/bash -eux

export HISTSIZE=0
export HISTFILESIZE=0

HOME_DIR="/home/vagrant"
VAGRANT_KEY="https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub"

apt-get --assume-yes update

mkdir -p "${HOME_DIR}/.ssh";
chmod 0700 "${HOME_DIR}/.ssh";
curl -sSL "${VAGRANT_KEY}" > "${HOME_DIR}/.ssh/authorized_keys";
chmod 0600 "${HOME_DIR}/.ssh/authorized_keys";
chown -R vagrant:vagrant "${HOME_DIR}";
