#!/bin/sh

logfile=$(mktemp)
dnf -y update | tee $logfile

if [ $(grep "^kernel-" $logfile) ] && [ $(date +%k) -lt 11 ]; then
    echo "Rebooting due to Kernel updates."
    shutdown -r now 
fi 

rm -f $logfile 

