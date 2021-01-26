#!/bin/sh

source /usr/local/osapp/osapp-vars.conf

for uuid in $(sudo nmcli connection show | awk {'print $2'} | grep -v ^UUID) ; do 
    nmcli connection delete $uuid 
done
