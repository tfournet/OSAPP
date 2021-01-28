#!/bin/sh

source /etc/osapp/osapp-vars.conf

dnf -y install httpd
systemctl enable --now httpd

firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

mkdir -p /var/www/html/opnsense

input_config="/usr/local/osapp/vm_setup/opnsense/conf/config.xml"
output_config="/var/www/html/opnsense/config.xml"

sed \
    -e "s/ZZZ-sitename-FW/$OPNsense_Hostname/g" \
    -e "s/sitename/$siteName/g" \
    -e "s/custdom.tld/$custTLD/g" \
    -e "s/\<rocommunity\>public\<\/rocommunity\>/\<rocommunity\>radermonitor\<\/rocommunity\>/g" \
    -e "s/10.10./10.$siteSubnet./g" \
    $input_config > $output_config 

lines=$(wc -l $output_config | awk {'print $1'}) 
echo "Wrote $lines lines to $output_config"

