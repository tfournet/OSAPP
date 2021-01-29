#!/bin/sh

# Created by Tim Fournet - tfournet@radersolutions.com

if ! [ -f /etc/osapp/osapp-vars.conf ] ; then
    sudo /usr/local/osapp/get_variables.sh 
fi

mkdir -p /etc/osapp 
conf=/etc/osapp/osapp-vars.conf 

# cp  /usr/local/osapp/osapp-vars.conf.dist $conf 

source /etc/osapp/osapp-vars.conf 

echo "Beginning Setup"



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

#virt-manager &


### VMs ###

# Import Perch VM
sudo $osapp_inst/vm_setup/perch/create_perch.sh

# Import Firewall VM(s)
sudo $osapp_inst/vm_setup/opnsense/create_opnsense.sh

# Boot Perch VM 
sudo $osapp_inst/vm_setup/perch/start_perch.sh 



### Containers ### 
sudo $osapp_inst/container_setup/podman.sh

# Create CyberCNS Container
sudo $osapp_inst/container_setup/cybercns/cybercns.sh 


echo "End Setup."


