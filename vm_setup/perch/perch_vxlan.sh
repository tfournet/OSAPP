#!/bin/sh

echo "Bringing up VXLAN monitor interface"

ip link add vxlan42 type vxlan id 42 remote 0.0.0.0 dstport 4789

ip link set vxlan42 up

