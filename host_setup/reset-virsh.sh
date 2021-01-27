#!/bin/sh

source /etc/osapp/osapp-vars.conf

$osapp_inst/vm_setup/perch/remove-perch.sh
$osapp_inst/vm_setup/opnesense/remove-opnsense.sh


for vlan in ${VLAN_IDs[@]}; do
   virsh destroy br-$vlan
   virsh net-undefine br-$vlan

done
virsh net-list
