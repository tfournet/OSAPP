#!/bin/sh

source /usr/local/osapp/osapp-vars.conf

cwa_LocID="zero"
while ! [ $cwa_LocID -eq $cwa_LocID 2>/dev/null ]; do 
    echo -n "ConnectWise Automate (LabTech) Site ID: "
    read cwa_LocID 
done 
sed -ie "s/^cwa_LocID=.*/cwa_LocID=$cwa_LocID/g" /usr/local/osapp/osapp-vars.conf 