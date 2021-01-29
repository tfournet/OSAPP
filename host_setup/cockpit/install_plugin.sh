#!/bin/sh

plugindir="/usr/local/share/cockpit/osapp"
mkdir -p $plugindir 


cp -var /usr/local/osapp/host_setup/cockpit/* $plugindir 

cockpit-bridge --packages 
