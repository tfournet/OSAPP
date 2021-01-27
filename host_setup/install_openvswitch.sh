#!/bin/sh

dnf -y install centos-release-openstack-train

dnf -y install openvswitch libibverbs install os-net-conf

systemctl enable --now openvswitch 

ovs-vsctl show 
 
"sed" os-netconfig.yaml to /etc/os-net-config/config.yaml
