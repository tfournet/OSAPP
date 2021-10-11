#!/bin/sh

source /etc/osapp/osapp-vars.conf 

# fixing up filesystem
guestfish --rw -a /var/lib/libvirt/pool0/Perch_Sensor-sda \
: run \
  : list-filesystems \
  : mount /dev/centos/root / \
  : mount /dev/centos/tmp /tmp \
  : mount /dev/centos/var /var \
  : mount /dev/sda1 /boot \
  : touch /testfile \
  : exit
  



#cho "Updating Packages"

echo "Setting root password"


echo "Adding passwordless login from host"
users=(root perch prairiefire)
#  authorized_key=$(cat /root/.ssh/ida_rsa.pub)
inject=""
for user in ${users[@]}; do
  inject="$inject --ssh-inject $user"
done
virt-sysprep   -d $Perch_VMName $inject
#virt-customize -d $Perch_VMName --chmod 0600:/root/.ssh/authorized_keys

perch_hostname=$Perch_Hostname 

sed -e "s/{{cwa_LocID}}/$cwa_LocID/g"  \
    -e "s/{{hostname}}/$perch_hostname/g" \
    -e "s/{{password}}/$password/g" \
    $osapp_inst/vm_setup/perch/perch_firstboot.sh > /tmp/perch_firstboot.sh
    chmod a+x /tmp/perch_firstboot.sh  
sed -e "s/{{sitesubnet}}/$siteSubnet/g" \
    $osapp_inst/vm_setup/perch/perch_ifcfg-eth0   > /tmp/ifcfg-eth0

virt-customize -d $Perch_VMName --copy-in /tmp/ifcfg-eth0:/etc/sysconfig/network-scripts/
virt-customize -d $Perch_VMName --copy-in $osapp_inst/install-labtech.sh:/usr/local/bin/
virt-customize -d $Perch_VMName --copy-in $osapp_inst/vm_setup/perch/perch_vxlan.sh:/usr/local/bin/
virt-customize -d $Perch_VMName --copy-in /tmp/perch_firstboot.sh:/usr/local/sbin/

firstboot_cmds="/usr/local/sbin/perch_firstboot.sh"
virt-customize -d $Perch_VMName --firstboot-command "$firstboot_cmds"
    
# Start VM
virsh start $Perch_VMName
virsh autostart $Perch_VMName

echo -n "Waiting for $Perch_VMName to boot.."
sleep 10

cp -f $osapp_inst/vm_setup/perch/perch_monitor.sh  /usr/local/bin/perch_monitor.sh
chmod a+x /usr/local/bin/perch_monitor.sh

grep -q "perch_monitor.sh" /etc/rc.local || echo "/usr/local/bin/perch_monitor.sh" >> /etc/rc.local
chmod a+x /etc/rc.local 

/usr/local/bin/perch_monitor.sh

echo "Waiting for Perch to go through its first boot processes..."
sleep 600

sshpass -p $password ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.10.20.3
sshpass -p $password ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no perch@10.10.20.3
sshpass -p $password ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no prairiefire@10.10.20.3
sshpass -p $password ssh root@10.10.20.3 "echo "$password" | passwd perch --stdin"
sshpass -p $password ssh root@10.10.20.3 "echo "$password" | passwd prairiefire --stdin"

rm -rf /tmp/perch

echo -e "\nPlease complete the configuration wizard for the site."
echo "ssh perch@10.$siteSubnet.20.3 "
