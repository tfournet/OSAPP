#!/bin/sh

# Created by Tim Fournet - tfournet@radersolutions.com
# Created 2020-11-25
# Updated 2021-01-25
myVersion=7

source /usr/local/osapp/osapp-vars.conf

echo "Beginning Secured Setup version $myVersion"


#testing mode############
#alias sudo="echo sudo"
#delete this to make stuff run for reals


# Get Installation Specifics

hostname=""
cns_location_identifier=""

# Create SSH Keys
cat /dev/zero | ssh-keygen -t rsa -q -N ""


# Add RMM Agent(s)

sudo $osapp_inst/install-labtech.sh $cwa_LocID

# Set up Hypervisor

sudo $osapp_inst/host_setup/host_kvm_setup.sh


# Set up Networking

sudo $osapp_inst/host_setup/host_networking.sh

virt-manager &


### VMs ###

# Import Firewall VM(s)
sudo $osapp_inst/vm_setup/opnsense/create_opnsense.sh

# Import Perch VM
echo sudo $osapp_inst/vm_setup/perch/create_perch.sh



### Containers ### 
sudo $osapp_inst/container_setup/podman.sh

# Create CyberCNS Container
echo sudo $osapp_inst/container_setup/cybercns/cybercns.sh 


echo "End Secured Setup."

# Install labtech

#sh /usr/local/osapp/install-labtech.sh $cwa_LocID

