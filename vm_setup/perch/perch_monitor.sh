#!/bin/sh

source /etc/osapp/osapp-vars.conf

while ( ! echo $dif | grep -q "vnet" ) ; do 
    dif=$(virsh domiflist Perch_Sensor | grep bridge | grep br.10 | awk {'print $1'}) 
    sleep 1 
done

mon_ports=("eno1" "eno2")
for sif in ${mon_ports[@]}; do
    echo "Ingress for port $sif to $dif"
    tc qdisc add dev $sif ingress
    tc filter add dev $sif parent ffff: \
             protocol all \
            u32 match u8 0 0 \
            action mirred egress mirror dev "$dif"

    echo "Egress for port $sif to $dif"
    tc qdisc add dev "$sif" handle 1: root prio
    tc filter add dev "$sif" parent 1: \
            protocol all \
            u32 match u8 0 0 \
            action mirred egress mirror dev "$dif"
done
