#!/bin/sh

# Created by Tim Fournet - tfournet@radersolutions.com
# Created 2020-11-25
# Updated 2021-01-25
myVersion=11

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
 

killall firefox

# Download secured files
clear

cd /usr/local
if [ -d osapp ]; then rm -rf osapp ; fi
sudo git clone https://github.com/tfournet/osapp 

echo "Beginning Setup"
echo /usr/local/osapp/osapp-setup.sh && echo "End configuration script." && sudo rm -f /need-setup


