#!/bin/sh

./remove-perch.sh
./remove-opnsense.sh


VLAN_IDs=(10 20 30 40 50 60 70 100)
for vlan in ${VLAN_IDs[@]}; do
   virsh destroy br-$vlan
   virsh net-undefine br-$vlan

done
virsh net-list
