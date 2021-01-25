#!/bin/sh

hostname="{{hostname}}"
echo "Setting system hostname to $hostname"
hostnamectl set-hostname $hostname 

echo "Removing Perch defaults leftover from VMWare Images"
redis-cli del pf.setup.nic.ens33 
redis-cli del pf.setup.nic.ens34 
service network restart 

echo "Installing Labtech Agent"
ping google.com -c1 && /usr/local/bin/install-labtech.sh {{cwa_LocID}} 

echo "Setting up VXLAN Traffic Collector"
grep -q 'perch_vxlan.sh' /etc/rc.local || echo '/usr/local/bin/perch_vxlan.sh' >> /etc/rc.local 
/usr/local/bin/perch_vxlan.sh 

echo "SeLinux fixups for SSH Key-based authentication"
restorecon -R -v /root/.ssh 
restorecon -R -v /home/perch/.ssh 
restorecon -R -v /home/prairiefire/.ssh 

echo "Updating Perch"
yum -y install perch_siem
perch_update_cmd="/opt/perch/setup/perch_update_yum"
$perch_update_cmd
ln -s $perch_update_cmd /etc/cron.weekly/


