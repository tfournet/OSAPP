#!/bin/sh

source /etc/osapp/osapp-vars.conf

rm -rf /usr/local/containers/cybercns* 

/usr/local/osapp/host_setup/reset_virsh.sh 

/usr/local/osapp/host_setup/reset_networking.sh 


