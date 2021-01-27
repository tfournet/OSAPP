#!/bin/sh


source /etc/osapp/osapp-vars.conf

(hostname | grep -qi "perch") && ifconfig bridge0 && echo "Exiting because Bridged Interface" && exit

cybercns_hostname=$cybercns_hostname
cybercns_site_id=$cybercns_siteId

containerdir=/usr/local/containers/cybercns-$cybercns_site_id

compose="podman-compose" 


mkdir -p $containerdir/{logs,salt,minion,cache,salt/minion.d}
echo 'id: '$cybercns_site_id > $containerdir/salt/minion.d/minion.conf
echo 'master: '$cybercns_hostname >> $containerdir/salt/minion.d/minion.conf
echo '
grains_cache: True
grains_cache_expiration: 86400
random_reauth_delay: 60
recon_default: 1000
recon_max: 59000
recon_randomize: True
' >> $containerdir/salt/minion.d/minion.conf

echo '
version: "3"
services:
  cybercnsvulnerabilityagent:
    container_name: cyberCNSAgent
    privileged: true
    image: "cybercnssaas/cybercns_agent"
    network_mode: host
    # environment:
    #   LOG_LEVEL: "debug"
    restart: always
    volumes:
      - "/opt/CyberCNSAgent/logs:/opt/CyberCNSAgent/logs"
      - "/opt/CyberCNSAgent/salt:/etc/salt"
      - "/opt/CyberCNSAgent/minion:/var/lib/salt/pki/minion"
      - "/opt/CyberCNSAgent/cache:/var/cache/salt"
' > $containerdir/docker-compose.yaml

cd $containerdir
$compose pull
$compose up -d 


