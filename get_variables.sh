#!/bin/sh

conf="/osapp/osapp-vars.conf"

cwa_LocID="zero"
while ! [ $cwa_LocID -eq $cwa_LocID 2>/dev/null ]; do 
    echo -n "ConnectWise Automate (LabTech) Site ID: "
    read cwa_LocID 
done 
sed -ie "s/^cwa_LocID=.*/cwa_LocID=$cwa_LocID/g" $conf 

compconfig="/usr/local/ltechagent/computer_config"
if [ -f $compconfig ]; then 
    cybercns_siteId=$(cat $compconfig | jq '.location_edf."CyberCNS Location Identifier"' --raw-output)
    sed -ie "s/^cybercns_siteId=.*/cybercns_siteId=$cybercns_siteId/g" $conf
    cybercns_custId=$(cat $compconfig | jq '.client_edf."CyberCNS Company ID"' --raw-output)
    sed -ie "s/^cybercns_custId=.*/cybercns_custId=$cybercns_custId/g" $conf
    custAbbr=$(cat $compconfig | jq '.client_edf."Abbreviation"' --raw-output)
    sed -ie "s/^custAbbr=.*/custAbbr=$custAbbr/g" $conf
    siteSubnet=$(cat $compconfig | jq '.location_edf."Site_Octet"' --raw-output)
    sed -ie "s/^siteSubnet=.*/siteSubnet=$siteSubnet/g" $conf
    siteSubdomain=$(cat $compconfig | jq '.location_edf."Site_Subdomain"' --raw-output)
    sed -ie "s/^siteName=.*/siteName=$siteSubdomain/g" $conf
    custTLD=$(cat $compconfig | jq '.location_edf."Primary Top-Level Domain"' --raw-output)
    echo "custTLD=\"$custTLD\"" >> $conf
fi 

OPNsense_Hostname="$custAbbr-$siteSubdomain-FW"
echo "OPNsense_Hostname=\"$OPNSense_Hostname\"" >> $conf 
Perch_Hostname="$custAbbr-$siteSubdomain-Perch"
echo "Perch_Hostname=\"$Perch_Hostname\"" >> $conf 


