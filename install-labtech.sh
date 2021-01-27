#!/bin/sh


source /usr/local/osapp/osapp-vars.conf || cwa_LocID=$1

tmpdir="/tmp/cwa"

if [[ ! $cwa_LocID -gt 0 ]]; then
    echo "ERROR: Labtech (CWA) LocationID is not set correctly"
    exit 1
    else "Setting Labtech LocationID to $cwa_LocID"
fi

which unzip || yum -y install unzip
which wget  || yum -y install wget 

rm -rf $tmpdir 2>/dev/null 
mkdir -p $tmpdir 


wget -O lt.zip http://labtech.radersolutions.com/labtech/transfer/installers/LTechAgent_x86_64_loc_412.zip

unzip lt.zip

cd LTechAgent 


sed -ie "s/LT_LOCATION_ID=.*/LT_LOCATION_ID=$cwa_LocID/g" install.sh

chmod a+x install.sh
./install.sh

ps axf | grep ltechagent 


