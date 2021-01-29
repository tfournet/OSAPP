#!/bin/sh

source /etc/osapp/osapp-vars.conf

# Set Hostname
hostnamectl set-hostname $OSAPP_Hostname 
hostnamectl set-location $siteName 

#rm -f ~/.ssh/known_hosts

## Delete existing physical interfaces
echo "Clearing existing configs"
nmcli connection delete $(nmcli connection show System\ eno1 | grep connection.uuid | awk '{print $2}')
nmcli connection delete $(nmcli connection show System\ eno2 | grep connection.uuid | awk '{print $2}')
nmcli connection delete $(nmcli connection show System\ eno3 | grep connection.uuid | awk '{print $2}')
nmcli connection delete $(nmcli connection show System\ eno4 | grep connection.uuid | awk '{print $2}')

nmcli connection show | awk {'print $2'} | xargs nmcli connection delete  ; nmcli connection show

for vnet in $(virsh net-list | grep "br"); do 
    virsh net-destroy $vnet
    virsh net-undefine $vnet 
done


## Create Team/bond on first two interfaces
type=$nicBondType
bondName=$type"0"
echo "Creating "$type"ed interface from first two NICs"
if [[ $type == "team" ]]; then
    $ConOptions="config '{"runner": {"name": "roundrobin"}}'"
else
    $ConOptions="bond.options "mode=balance-xor" ipv4.method manual ipv6.method ignore"
fi
nmcli connection add type $type    con-name $bondName ifname $bondName $ConOptions
nmcli connection add type ethernet con-name $bondName-slave0 ifname eno1 master $bondName slave-type $type
nmcli connection add type ethernet con-name $bondName-slave1 ifname eno2 master $bondName slave-type $type
nmcli connection up $bondName-slave0
nmcli connection up $bondName-slave1


#echo "Creating Bridge from $type"
#bridgeName="br-"$bondName
#nmcli connection add type bridge autoconnect yes con-name $bridgeName ifname $bridgeName ipv4.method disabled
#nmcli connection add type ethernet slave-type bridge con-name br-slave ifname team0 master br-team0

bridgeName="br-"$bondName
nmcli connection add type bridge con-name $bridgeName ifname $bridgeName stp no autoconnect yes
nmcli connection mod $bondName connection.slave-type bridge connection.master $bridgeName
nmcli connection mod $bondName ipv4.method auto 

## Overlay VLANs on top of bridged team
echo "Configuring VLAN Bridges"
for vlan in ${VLAN_IDs[@]}; do
   master=$bondName
   bridgeName=br.$vlan
   echo "Configuring VLAN $vlan on link: $master"
   if=$bondName.$vlan
   
   nmcli connection add type bridge con-name $bridgeName ifname $bridgeName stp no autoconnect yes
   nmcli connection add type vlan con-name $if ifname $if dev $bondName id $vlan master $bridgeName connection.autoconnect yes
   
   nmcli connection down $bridgeName
   nmcli connection up   $bridgeName

   echo "<network><name>$bridgeName</name><forward mode=\"bridge\"/><bridge name=\"$bridgeName\"/></network>" > /tmp/$bridgeName.xml 
   sync
   virsh net-define --file /tmp/$bridgeName.xml  
   virsh net-autostart $bridgeName
   virsh net-start $bridgeName
done

virsh net-list


## Set IP for this host on VLAN 20
echo -n "Setting Primary IP Address "
vlan="20"
ifname=br.$vlan
ipaddr="10.$siteSubnet.$vlan.2/24"
gateway="10.$siteSubnet.$vlan.1"
locdns=$gateway
echo "for $ifname to $ipaddr"
#nmcli connection modify $ifname ifname $ifname dev $bondName id $vlan
nmcli connection modify $ifname ipv4.method manual ipv4.address $ipaddr ipv4.gateway $gateway
nmcli connection modify $ifname ipv4.dns  $locdns
for dns_server in ${Allowed_DNS[@]}; do
    nmcli connection modify $ifname +ipv4.dns $dns_server
done
nmcli connection down   $ifname
nmcli connection up     $ifname 

## Set IP for this host on VLAN 10 (temporary)
tempip="192.168.1.2"
echo -n "Setting Temporary IP Address $temip"
vlan="10"
ifname=br.$vlan
ipaddr="192.168.1.2/24"
echo "for $ifname to $ipaddr"
nmcli connection modify $ifname ipv4.method manual ipv4.address $ipaddr
#for dns_server in ${Allowed_DNS[@]}; do
#    nmcli connection modify $ifname +ipv4.dns $dns_server
#done
nmcli connection down   $ifname
nmcli connection up     $ifname 
#ifconfig $ifname $tempip 255.255.255.0

sleep 10 
echo -e "\n\n\n"
nmcli connection show
