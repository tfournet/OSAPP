#!/bin/sh

source /usr/local/osapp/osapp-vars.conf

dnf -y module-install virt
dnf -y install virt-install virt-viewer libguestfs-tools virt-v2v
systemctl enable libvirtd.service
systemctl start libvirtd.service

mkdir -p /var/lib/libvirt/$vpool
virsh pool-define-as pool0 --type dir --target /var/lib/libvirt/$vpool
virsh pool-start $vpool
virsh pool-autostart $vpool

virsh pool-list


