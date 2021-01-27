#!/bin/sh

echo "Bringing up VXLAN monitor interface"

ip link add vxlan42 type vxlan id 42 dev eth0 local 10.10.{{siteSubnet}}.3 dstport 4789
ip address add 172.20100.10/24 dev vxlan42 
ip link set vxlan42 up

