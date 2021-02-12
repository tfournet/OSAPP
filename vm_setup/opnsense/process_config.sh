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

cmd="curl -o /conf/config.xml http://192.168.1.2/opnsense/config.xml ; cat /conf/config.xml"
pass="opnsense"
echo "Next we will log into $OPNSense_VMName and run: $cmd"

/usr/local/osapp/vm_setup/opnsense/opnsense_console_cmd.sh $OPNSense_VMName $pass /tmp/exp-opnsense "$cmd" 

#echo "Restarting $OPNSense_VMName"
#virsh shutdown $OPNSense_VMName
#sleep 30
#virsh start $OPNSense_VMName
#sleep 90

#echo "Adding SSH Key to OPNsense"

#alias sshcon="ssh -O StrictHostKeyChecking=no"
#sshpass -p 'raderChangeme!' scp $output_config root@192.168.1.1:/conf/config.xml
#sshpass -p 'raderChangeme!' ssh -o StrictHostKeyChecking=no root@192.168.42.1 "shutdown -r now"

opn_ip="10.$siteSubnet.20.1"
while ! (ping $opn_ip -c 20) ; do echo offline ; sleep 1 ; done

echo "Updating OPNsense & Rebooting"
sshpass -p $password ssh -o StrictHostKeyChecking=no root@$opn_ip "opnsense-update ; shutdown -r now"
sleep 20 
while ! (ping $opn_ip -c 20) ; do echo offline ; sleep 1 ; done

echo "Updating Plugins"
sshpass -p $password ssh -o StrictHostKeyChecking=no root@$opn_ip "uptime; echo 'Syncing Plugins....' ; /usr/local/opnsense/scripts/firmware/sync.sh"

echo "Rebooting"
sshpass -p $password ssh -o StrictHostKeyChecking=no root@$opn_ip "shutdown -r now"
sleep 20 
while ! (ping $opn_ip -c 20) ; do echo offline ; sleep 1 ; done

sshpass -p $password ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@$opn_ip



