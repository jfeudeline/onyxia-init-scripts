#!/bin/bash

# Chargement des clés SSH

mc cp $PATH_TO_SSHKEY/id_ed25519.pub ~/.ssh/id_ed25519.pub
mc cp $PATH_TO_SSHKEY/id_ed25519 ~/.ssh/id_ed25519

# Installation de Terraform

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform

# Installation de l'extension Terraform dans VSCode

code-server --install-extension hashicorp.terraform

