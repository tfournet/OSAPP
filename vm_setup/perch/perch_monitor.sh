#!/bin/sh

source /usr/local/osapp/osapp-vars.conf

MONITOR_PORT="br-bond0"
#MIRROR_PORT="perchmon"

## Ingress
#tc qdisc add dev $MONITOR_PORT ingress
#tc filter add dev $MONITOR_PORT parent ffff: protocol all u32 match u8 0 0 action mirred egress mirror dev $MIRROR_PORT

## Egress
#tc qdisc add dev $MONITOR_PORT handle 1: root prio
#tc filter add dev $MONITOR_PORT parent 1: protocol all u32 match u8 0 0 action mirred egress mirror dev $MIRROR_PORT

sif=$MONITOR_PORT
dif=vxlan42
sensor=10.$siteSubnet.20.3

echo "Creating Monitor port $sif to mirror to sensor IP $sensor"

bridge fdb append to 00:00:00:00:00:00 dst "$sensor" dev vxlan0
ip link set vxlan42 up
# ingress
tc qdisc add dev "$sif" ingress
tc filter add dev "$sif" parent ffff: \
          protocol all \
          u32 match u8 0 0 \
          action mirred egress mirror dev "$dif"

# egress
tc qdisc add dev "$sif" handle 1: root prio
tc filter add dev "$sif" parent 1: \
          protocol all \
          u32 match u8 0 0 \
          action mirred egress mirror dev "$dif"

