#!/bin/sh

source /etc/osapp/osapp-vars.conf


firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

webdir="/usr/share/nginx/html/opnsense"
mkdir -p $webdir 

input_config="/usr/local/osapp/vm_setup/opnsense/conf/config.xml"
output_config="$webdir/config.xml"

perch_mac=$(virsh domiflist $Perch_VMName | grep br.20 | awk {'print $5'})

echo $custTld 

sed \
    -e "s/ZZZ-sitename-FW/$OPNsense_Hostname/g" \
    -e "s/sitename/$siteName/g" \
    -e "s#custtld#$custTld#g" \
    -e "s#<rocommunity>.*.</rocommunity>#<rocommunity>$snmpCommunity</rocommunity>#g" \
    -e "s/10.10./10.$siteSubnet./g" \
    -e "s#<mac>.*.</mac>#<mac>$perch_mac</mac>#g" \
    $input_config > $output_config 

lines=$(wc -l $output_config | awk {'print $1'}) 
echo "Wrote $lines lines to $output_config"

cmd="curl -o /conf/config.xml http://192.168.1.2/opnsense/config.xml && cat /conf/config.xml"
pass="opnsense"
echo "Next we will log into $OPNSense_VMName and run: $cmd"

/usr/local/osapp/vm_setup/opnsense/opnsense_console_cmd.sh $OPNSense_VMName $pass /tmp/exp-opnsense "$cmd" 

echo "Adding SSH Key to OPNsense"


echo "Updating OPNsense"
sshpass -p $password ssh -o StrictHostKeyChecking=no root@10.10.20.1 opnsense-update 
sshpass -p $password ssh -o StrictHostKeyChecking=no root@10.10.20.1 /usr/local/opnsense/scripts/firmware/sync.sh
echo "" 
sshpass -p $password ssh-copy-id -o StrictHostKeyChecking=no root@10.10.20.1
sshpass -p $password ssh -o StrictHostKeyChecking=no root@10.10.20.1 "shutdown -r now"

shpass -p $password ssh -o StrictHostKeyChecking=no root@10.10.20.1 "shutdown -r now"

