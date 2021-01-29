#!/bin/sh

# Created by Tim Fournet - tfournet@radersolutions.com


mkdir -p /etc/osapp 
conf=/etc/osapp/osapp-vars.conf 

sudo /usr/local/osapp/get_variables.sh 

# cp  /usr/local/osapp/osapp-vars.conf.dist $conf 

source $conf 

echo "Beginning Setup"

# Add RMM Agent(s)

if  [ $cwa_LocID -eq $cwa_LocID ] && [ $cwa_LocID ]; then
  sudo $osapp_inst/install-labtech.sh $cwa_LocID
else
  echo -n "Enter CWA Location ID: "
  read cwa_LocID
  sudo $osapp_inst/install-labtech.sh $cwa_LocID
fi

# Install cockpit addons
dnf -y install cockpit-dashboard cockpit-machine cockpit-session-recording

#testing mode############
#alias sudo="echo sudo"
#delete this to make stuff run for reals

sudo $osapp_inst/get_variables.sh 

# Create SSH Keys
cat /dev/zero | ssh-keygen -t rsa -q -N ""




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
sudo $osapp_inst/container_setup/cybercns/cybercns.sh 


echo "End Setup."


