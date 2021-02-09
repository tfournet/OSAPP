#!/bin/sh


hostname="{{hostname}}"
cwa_LocID={{cwa_LocID}}
password="{{password}}"

echo "Setting system hostname to $hostname"
hostnamectl set-hostname $hostname 

echo "Setting root password"
echo $password | passwd --stdin root

echo "Removing Perch defaults leftover from VMWare Images"
redis-cli del pf.setup.nic.ens33 
redis-cli del pf.setup.nic.ens34 
service network restart 

echo "Installing Labtech Agent"
if [[ $cwa_LocID -gt 0 ]]; then 
    ping google.com -c4 && /usr/local/bin/install-labtech.sh $cwa_LocID 
fi 

echo "Setting up VXLAN Traffic Collector"
grep -q 'perch_vxlan.sh' /etc/rc.local || echo '/usr/local/bin/perch_vxlan.sh' >> /etc/rc.local 
chmod a+x /usr/local/bin/perch_vxlan.sh 
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

rm -f /usr/local/sbin/perch_firstboot.sh

