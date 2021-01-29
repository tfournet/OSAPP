#!/bin/sh

source /etc/osapp/osapp-vars.conf

monitorPort="perchmon"

firstboot_cmds=""

# Download and Import VM
mkdir -p /tmp/perch

dlfile="/tmp/perch/perch_sensor.ova"

while ! [ -f $dlfile ]; do 
  wget -O $dlfile $Perch_URL
done

echo "Extracting and Converting Image..."
virt-v2v -i ova /tmp/perch/perch_sensor.ova -of qcow2 -os $vpool -on $Perch_VMName

echo "Removing Existing Interfaces"
virt-xml -d $Perch_VMName --remove-device --network all

echo "Adding New Interfaces"
virsh attach-interface --domain $Perch_VMName --type bridge --source br.20 --model virtio --config 
virsh attach-interface --domain $Perch_VMName --type bridge --source br.10 --model virtio --config 


virsh domiflist --domain $Perch_VMName 
