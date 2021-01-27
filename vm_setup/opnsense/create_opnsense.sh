#!/bin/sh

source /usr/local/osapp/osapp-vars.conf

dlfile="OPNsense.img.bz2"
tmpdir="/tmp/opnsense"


rm -rf $tmpdir 2>/dev/null
mkdir -p $tmpdir
cd $tmpdir

echo "Downloading OPNSense Image from $OPNSense_URL"
if [ -f /tmp/$dlfile ]; then
  cp /tmp/$dlfile $tmpdir
else
  curl -o $tmpdir/$dlfile $OPNSense_URL
  cp $tmpdir/$dlfile /tmp
fi
Download_SHA256=$(sha256sum $dlfile | awk {'print $1'})

echo "Comparing Downloaded file checksum: $Download_SHA256"
echo "with Vendor-provided file checksum: $OPNSense_SHA256"

if [[ $Download_SHA256 != $OPNSense_SHA256 ]] ; then
  echo "ERROR: Unable to verify authenticity of downloaded OPNSense Package. Please check the variables file https://github.com/RaderSolutions/osapp/osapp-vars.conf for up to date URLs and SHA256sums"
  echo "Repair this and try again"
  exit 100
else 
  echo "Hashes match"
fi

echo "Extracting Image"
bzip2 -vdf $dlfile

echo "Converting and Importing VM Image"
qemu-img convert -f raw -O qcow2 OPNsense.img $OPNSense_VMName.qcow2
qemu-img resize $OPNSense_VMName.qcow2 +8G
mv -f $OPNSense_VMName.qcow2 /var/lib/libvirt/pool0/$OPNSense_VMName.qcow

defaultBridge="br-"$nicBondType"0"

virtInstallOpts="\
    --print-xml \
    --import \
    --virt-type=kvm \
    --name $OPNSense_VMName \
    --memory 16384 \
    --vcpus=3 \
    --os-variant=freebsd12.0 \
    --console pty,target_type=serial \
    --disk /var/lib/libvirt/pool0/$OPNSense_VMName.qcow \
    -v \
    "
#    --network=bridge=$defaultBridge,model=virtio \

for vlan in ${VLAN_IDs[@]}; do
  virtInstallOpts="\
    $virtInstallOpts \
    --network=bridge=br.$vlan,model=virtio \
    "
done


echo Creating $OPNSense_VMName VM with Options $virtInstallOpts

wan0="--add-device --network=source=eno3,type=direct,model=virtio,source_mode=vepa --print-xml"
wan1="--add-device --network=source=eno4,type=direct,model=virtio,source_mode=vepa --print-xml"

virt-install $virtInstallOpts | virt-xml $wan0 | virt-xml $wan1 > $OPNSense_VMName.xml

#virsh attach-interface --domain $OPNSense_VMName --type bridge --source br-$vlan --model virtio --config
virsh define $OPNSense_VMName.xml 

virsh start $OPNSense_VMName

#virt-manager --connect qemu:///system --show-domain-console $OPNSense_VMName &

rm -rf /tmp/opnsense


$osapp/inst/vm_setup/opnsense/process_config.sh 


sleeptime="3m"
echo "Sleeping $sleeptime"
sleep $sleeptime

cmd="curl -o /conf/config.xml http://192.168.1.2/opnsense/config.xml && shutdown -r now"
pass="opnsense"
echo "Next we will log into $OPNSense_VMName and run: $cmd"
echo -e "\n\n"

$osapp_inst/vm_setup/opnsense/opnsense_console_cmd.sh $OPNSense_VMName $pass /tmp/exp-opnsense $cmd &

systemctl stop httpd
systemctl disable httpd
