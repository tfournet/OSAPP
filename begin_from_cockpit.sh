#!/bin/sh

custAbbr=$1
custTld=$2
siteSubnet=$3
extDns1=$4
extDns2=$5
cybercns_hostname=$6
cybercns_siteId=$7
Perch_URL=$8
OPNSense_URL=$9
OPNSense_SHA256=${10}

mkdir -p /etc/osapp 
conf="/etc/osapp/osapp-vars.conf"

echo """
osapp_inst=\"/usr/local/osapp\"
vpool=\"pool0\"
nicBondType=\"bond\"
VLAN_IDs=(10 20 30 40 50 60 70 80 100)
OSAPP_Hostname=
Perch_Hostname=
OPNsense_Hostname= 
OPNSense_VMName=\"OPNsense_Firewall\"
Perch_VMName=\"Perch_Sensor\"
custAbbr=\"$1\"
custTld=\"$2\"
siteSubnet=\"$3\"
Allowed_DNS=(\"$4\" \"$5\")
cybercns_hostname=\"$6\"
cybercns_siteId=\"$7\"
Perch_URL=\"$8\"
OPNSense_URL=\"$9\"
OPNSense_SHA256=\"${10}\"
""" > $conf 

tmpScript="/usr/local/bin/run-osapp-setup.sh"
rm -f $tmpScript 
echo '#!/bin/sh

touch /tmp/osapp-setup-running

source /etc/osapp/osapp-vars.conf 
echo "Beginning Setup"

# Install OS addons
dnf -y install epel-release
dnf -y install cockpit-dashboard cockpit-machine cockpit-session-recording

cat /dev/zero | ssh-keygen -t rsa -q -N ""

# Set up Hypervisor
/usr/local/osapp/host_setup/host_kvm_setup.sh

# Set up Networking
/usr/local/osapp/host_setup/host_networking.sh

# Import Firewall VM(s)
/usr/local/osapp/vm_setup/opnsense/create_opnsense.sh

# Import Perch VM
/usr/local/osapp/vm_setup/perch/create_perch.sh

# Configure Firewall VM
/usr/local/osapp/vm_setup/opnsense/process_config.sh 

# Boot Perch VM 
/usr/local/osapp/vm_setup/perch/start_perch.sh 

### Ready for Containers ### 
/usr/local/osapp/container_setup/podman.sh

# Create CyberCNS Container
/usr/local/osapp/container_setup/cybercns/cybercns.sh 


echo "End Setup."
rm -f /tmp/osapp-setup-running
' > $tmpScript

chmod a+x $tmpScript 
systemd-run --unit=OSAPP-Setup $tmpScript
journalctl -f -u OSAPP-Setup 



