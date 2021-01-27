#!/bin/sh

source /etc/osapp/osapp-vars.conf

monitorPort="perchmon"

firstboot_cmds=""

# Download and Import VM
mkdir -p /tmp/perch

dlfile="/tmp/perch_sensor.ova"

echo "Downloading Perch Appliance Image from $Perch_URL"
if [[ -f /tmp/$dlfile ]]; then
  cp /tmp/$dlfile $tmpdir
  echo "File exists already"
else
  curl -o $tmpdir/$dlfile $Perch_URL
  cp $tmpdir/$dlfile /tmp
fi

#ls
wget -O /tmp/perch/perch_sensor.ova $Perch_URL

echo "Extracting and Converting Image..."
virt-v2v -i ova /tmp/perch/perch_sensor.ova -of qcow2 -os $vpool -on $Perch_VMName


# Customizing VM Setup
## Create Perch Monitor Port
#nmcli connection delete con-name $monitorPort
#nmcli connection add type bridge con-name $monitorPort ifname $monitorPort ipv4.method disabled ipv6.method ignore



echo "Removing Existing Interfaces"
virt-xml -d $Perch_VMName --remove-device --network all

echo "Adding New Interfaces"
virsh attach-interface --domain $Perch_VMName --type bridge --source br.20 --model virtio --config 

virsh domiflist --domain $Perch_VMName 


# fixing up filesystem
guestfish -rw -a /var/lib/libvirt/pool0/Perch_Sensor-sda \
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

perch_hostname="$custAbbr-$siteName-Perch"

sed -ie "s/{{cwa_LocID}}/$cwa_LocID/g"     $osapp_inst/vm_setup/perch/perch_firstboot.sh
sed -ie "s/{{hostname}}/$perch_hostname/g" $osapp_inst/vm_setup/perch/perch_firstboot.sh 
sed -e  "s/{{sitesubnet}}/$siteSubnet/g"   $osapp_inst/vm_setup/perch/perch_ifcfg-eth0 > /tmp/ifcfg-eth0

virt-customize -d $Perch_VMName --copy-in /tmp/ifcfg-eth0:/etc/sysconfig/network-scripts/
virt-customize -d $Perch_VMName --copy-in $osapp_inst/vm_setup/install-labtech.sh:/usr/local/bin/
#virt-customize -d $Perch_VMName --chmod 0755:/usr/local/bin/install-labtech.sh
virt-customize -d $Perch_VMName --copy-in $osapp_inst/vm_setup/perch/perch_vxlan.sh:/usr/local/bin/
#virt-customize -d $Perch_VMName --chmod 0755:/usr/local/bin/perch_vxlan.sh
virt-customize -d $Perch_VMName --copy-in $osapp_inst/vm_setup/perch/perch_firstboot.sh:/usr/local/bin/
#virt-customize -d $Perch_VMName --chmod 0755:/usr/local/bin/perch_firstboot.sh

firstboot_cmds="/usr/local/bin/perch_firstboot.sh"
virt-customize -d $Perch_VMName --firstboot-command "$firstboot_cmds"




    
# Start VM
virsh start $Perch_VMName
virsh autostart $Perch_VMName
sleep 2

#virt-manager --connect qemu:///system --show-domain-console Perch_Sensor &

echo -n "Waiting for $Perch_VMName to boot.."
sleep 10

cp -f $osapp_inst/vm_setup/perch/perch_monitor.sh  /usr/local/bin/perch_monitor.sh
chmod a+x /usr/local/bin/perch_monitor.sh

grep -q "perch_monitor.sh" /etc/rc.local || echo "/usr/local/bin/perch_monitor.sh" >> /etc/rc.local
chmod a+x /etc/rc.local 

/usr/local/bin/perch_monitor.sh

echo -e "\nLogging into Perch Sensor. Please complete the configuration wizard for the site."
ssh -o 'StrictHostKeyChecking no' perch@10.$siteSubnet.20.3 


#rm -rf /tmp/perch