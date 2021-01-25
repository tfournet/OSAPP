#!/bin/sh

source /usr/local/osapp/osapp-vars.conf

virsh destroy --domain $OPNSense_VMName
virsh undefine --domain $OPNSense_VMName
rm -f /var/lib/libvirt/pool0/$OPNSense_VMName.qcow

