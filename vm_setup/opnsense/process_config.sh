#!/bin/sh

source /etc/osapp/osapp-vars.conf


firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

dnf -y install httpd
systemctl start httpd

mkdir -p /var/www/html/opnsense

input_config="/usr/local/osapp/vm_setup/opnsense/conf/config.xml"
output_config="/var/www/html/opnsense/config.xml"

sed \
    -e "s/myhostname/$OPNsense_Hostname/g" \
    -e "s/sitename/$siteName/g" \
    -e "s/custdom.tld/$custTLD/g" \
    -e "s/\<rocommunity\>public\<\/rocommunity\>/\<rocommunity\>radermonitor\<\/rocommunity\>/g" \
    -e "s/10.10./10.$siteSubnet./g" \
    $input_config > $output_config 