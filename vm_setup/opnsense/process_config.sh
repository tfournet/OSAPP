#!/bin/sh

source /usr/local/osapp/osapp-vars.conf


firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

dnf -y install httpd
systemctl start httpd

mkdir -p /var/www/html/opnsense

input_config="$osapp_inst/vm_setup/opnsense/conf/config.xml"
output_config="/var/www/html/opnsense/config.xml"


