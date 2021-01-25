#!/bin/sh

# Created by Tim Fournet - tfournet@radersolutions.com
# Created 2020-11-25
# Updated 2020-12-01
myVersion=6

source /usr/local/osapp/osapp-vars.conf

echo "Beginning Secured Setup version $myVersion"

chmod a+x *.sh

# Get Installation Specifics

hostname=""
cns_location_identifier=""

#az group list

# Add RMM Agent(s)

# Set up Hypervisor

sudo ./kvm-setup.sh

# Set up Networking

sudo ./osapp-networking.sh

virt-manager &

# Import Firewall VM(s)

sudo ./opnsense.sh




# Import Perch VM

sudo ./perchsensor.sh



echo "Configuring Network Interfaces"

echo "Importing into Hypervisor"

# Create CyberCNS Container


echo "End Secured Setup."

# Install labtech

#sh /usr/local/osapp/install-labtech.sh $cwa_LocID

