# OSAPP
OnSite Appliance

kickstart url: https://git.io/Jt8MR

temporary kickstart password is: 'osapp-changeme'

This builds an all-in-one appliance for a [mostly] Open Source network security stack for small offices. 

Targeted hardware is the HPE Microserver Gen10Plus, but this can easily be expanded by altering the kickstart file. I chose this equipment because it is a very small form factor (about the size of a Dell/HP desktop PC), mostly silent, it takes up to 4 HDDs, 32GB RAM, a Quad Core Xeon processor, and has 4 on-board gigabit NICs with ports for 2 more PCI cards (10G capable).

The Operating System is RHEL/CentOS 8 or 8-Stream, booted up with the kickstart file in this repo (add inst.ks=https://git.io/Jt8MR to the end of the kernel line on bootup)

This installs the OS and a Cockpit plugin to start the configuration via a web UI. Entering in the site details sets up the following:

* OPNsense Firewall - Configured with a good set of security defaults, including network segmentation
* Perch Sensor VM - Downloaded from https://perchsecurity.com
* CyberCNS Vulnerability Management Software - Onsite datacollection container - https://www.cybercns.com 
* Additional stuff to come
  * Honeypot container or VM?
  * Backup software maybe?
  * Domain Imposter scanning https://github.com/tfournet/imp_hunter
  * Swap in different firewall distributions - CheckPoint? 
  
## Features ##
* Isolated Networks via VLAN: Networking Equipment | Servers | Printers | DMZ | Desktops | IoT | DVR | VoIP
* Whitelisting required for inter-VLAN traffic, a minimal set of rules are preconfigured
* OPNsense Firewall
  * Graphical representations of live traffic
  * User-friendly configuration of firewalls, routing, VPN, IPS
  * Sensei IPS blocks malicious traffic and allows application control / web filters
  * Dual WAN Interfaces passed directly through from host
* Perch Sensor
  * Traffic is mirrored from each VLAN to the Perch Sensor using the host operating system
  * Logging data (syslog) streamed from firewall and host server
  * Palo-style Blocklists from Perch to OPNsense config
* Containers using Podman
  * Currently this runs a CyberCNS container if a site identifier is entered




  
Network traffic is automatically collected and passed into Perch for analysis 

## QuickStart ##
1. Create CentOS (or equivalent) 8 boot flash
2. Boot into the image, and edit the 'linux' line, adding 'inst.ks=https://git.io/Jt8MR' to the end
3. Press Ctrl-X to boot with these parameters
4. After installation, browse to the Cockpit URL showing in the login motd.
5. Run the 'Setup OSAPP' applet in there
6. Enter the desired variables for the location. The idea is that IP addressing will be based on the following schema:
   `10.<Site Identifier>.<VLAN>.<Device>`
7. The process takes about 15 minutes, during which it downloads images of OPNsense and Perch, configures and boots them to the specified parameters

