#!/bin/sh

# Created by Tim Fournet - tfournet@radersolutions.com
# Created 2020-11-25
# Updated 2020-11-25
myVersion=10

clear
echo "Beginning configuration. Version $myVersion"

killall yelp

sleep 2

# Install Azure repo

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc


echo """
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
""" | sudo tee /etc/yum.repos.d/azure-cli.repo

sudo dnf -y install azure-cli epel-release git jq
sudo dnf -y update
 
# Get Azure Secret for SSH Keys

echo "Log into Azure with your credentials."
az login -t radersolutions.com

mkdir -p /root/.ssh
chmod 700 /root/.ssh
privkey64=$(az keyvault secret show --name osapp-root-privateKey --vault-name osapp-keyvault  | jq -r .value)
echo $privkey64 | sed -e "s/\ //g" | base64 --decode | sudo tee /root/.ssh/id_rsa
sudo chmod 600 /root/.ssh/id_rsa

pubkey=$(az keyvault secret show --name osapp-root-publicKey --vault-name osapp-keyvault  | jq -r .value)
echo $pubkey | sudo tee /root/.ssh/id_rsa.pub
sudo chmod 644 /root/.ssh/id_rsa.pub

killall firefox

# Download secured files
clear

cd /usr/local
if [ -d osapp ]; then rm -rf osapp ; fi
sudo git clone ssh://git@github.com/radersolutions/osapp
echo "Beginning Setup"
echo sh osapp/osapp-setup.sh

echo "End configuration script."
sudo rm -f /need-setup
