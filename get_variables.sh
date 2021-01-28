#!/bin/sh

conf="/etc/osapp/osapp-vars.conf"

if [ ! -f /usr/local/ltechagent/ltechagent ]; then 
    echo "ERROR Labtech not installed"
    exit 101 
fi

compconfig="/usr/local/ltechagent/computer_config"
 
while [ ! -f $compconfig ]; do 
    echo "Waiting for labtech computer config to update. You can speed this up by going into CWA" 
    echo "And performing a 'Resend Everything' Command"
    sleep 10
done 

cwa_LocID="zero"
while ! [ $cwa_LocID -eq $cwa_LocID 2>/dev/null ]; do 
    echo -n "ConnectWise Automate (LabTech) Site ID: "
    read cwa_LocID 
done 
sed -ie "s/^cwa_LocID=.*/cwa_LocID=$cwa_LocID/g" $conf 


if [ -f $compconfig ]; then 
    cybercns_siteId=$(cat $compconfig | jq '.location_edf."CyberCNS Location Identifier"' --raw-output)
    echo "CWA Site ID $siteID"
    sed -ie "s/^cybercns_siteId=.*/cybercns_siteId=$cybercns_siteId/g" $conf
    cybercns_custId=$(cat $compconfig | jq '.client_edf."CyberCNS Company ID"' --raw-output)
    echo "CyberCNS Customer $cybercns_custId"
    sed -ie "s/^cybercns_custId=.*/cybercns_custId=$cybercns_custId/g" $conf
    custAbbr=$(cat $compconfig | jq '.client_edf."Abbreviation"' --raw-output)
    echo "Customer Abbreviation $custAbbr"
    sed -ie "s/^custAbbr=.*/custAbbr=$custAbbr/g" $conf
    siteSubnet=$(cat $compconfig | jq '.location_edf."Site_Octet"' --raw-output)
    echo "Site Subnet 10.$siteSubnet.X.Y"
    sed -ie "s/^siteSubnet=.*/siteSubnet=$siteSubnet/g" $conf
    siteSubdomain=$(cat $compconfig | jq '.location_edf."Site_Subdomain"' --raw-output)
    sed -ie "s/^siteName=.*/siteName=$siteSubdomain/g" $conf
    custTLD=$(cat $compconfig | jq '.location_edf."Primary Top-Level Domain"' --raw-output)
    sed -ie "s/^custTLD=.*/custTLD=$custTLD/g" $conf
    echo "Site SubDomain $siteSubdomain.$custTLD"
    OSAPP_Hostname="$custAbbr-$siteSubdomain-OSAPP"
    echo "OSAPP Hostname $OSAPP_Hostname"
    sed -ie "s/^OSAPP_Hostname=.*/OSAPP_Hostname=$OSAPP_Hostname/g" $conf
    OPNsense_Hostname="$custAbbr-$siteSubdomain-FW"
    echo "OPNsense Hostname $OPNsense_Hostname"
    sed -ie "s/^OPNsense_Hostname=.*/OPNsense_Hostname=$OPNsense_Hostname/g" $conf 
    Perch_Hostname="$custAbbr-$siteSubdomain-Perch"
    echo "Perch Hostname $Perch_Hostname"
    sed -ie "s/^Perch_Hostname=.*/Perch_Hostname=$Perch_Hostname/g" $conf
fi 



