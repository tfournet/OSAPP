#!/bin/sh

source /etc/osapp/osapp-vars.conf

virsh destroy $Perch_VMName
virsh destroy $OPNSense_VMName
virsh undefine $Perch_VMName
virsh undefine $OPNSense_VMName

docker ps | grep -v ^CONTAINER | awk {'print $1'} | xargs docker stop
docker images | grep -v ^REPO | awk {'print $3'} | xargs docker rmi 

rm -rf /usr/local/containers/cybercns* 

/usr/local/osapp/host_setup/reset_virsh.sh 

/usr/local/osapp/host_setup/reset_networking.sh 
/usr/local/osapp/host_setup/host_networking.sh 

rm -rf /etc/osapp 

/usr/local/ltechagent/uninstaller.sh 

