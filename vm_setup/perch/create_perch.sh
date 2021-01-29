#!/bin/sh

source /etc/osapp/osapp-vars.conf

monitorPort="perchmon"

firstboot_cmds=""

# Download and Import VM
mkdir -p /tmp/perch

dlfile="/tmp/perch_sensor.ova"

echo "Downloading Perch Appliance Image from $Perch_URL"
if [[ -f /tmp/$dlfile ]]; then
  cp /tmp/$dlfile $tmpdir
  echo "File exists already"
else
  curl -o $tmpdir/$dlfile $Perch_URL
  cp $tmpdir/$dlfile /tmp
fi

#ls
#wget -O /tmp/perch/perch_sensor.ova $Perch_URL

echo "Extracting and Converting Image..."
virt-v2v -i ova /tmp/perch/perch_sensor.ova -of qcow2 -os $vpool -on $Perch_VMName


# Customizing VM Setup
## Create Perch Monitor Port
#nmcli connection delete con-name $monitorPort
#nmcli connection add type bridge con-name $monitorPort ifname $monitorPort ipv4.method disabled ipv6.method ignore



echo "Removing Existing Interfaces"
virt-xml -d $Perch_VMName --remove-device --network all

echo "Adding New Interfaces"
virsh attach-interface --domain $Perch_VMName --type bridge --source br.20 --model virtio --config 
virsh attach-interface --domain $Perch_VMName --type bridge --source br.10 --model virtio --config 


virsh domiflist --domain $Perch_VMName 
