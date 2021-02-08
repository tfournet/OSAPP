# OSAPP
OnSite Appliance

kickstart url: https://git.io/Jt8MR

temporary password is: 'raderChangeme!'

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
  
  
Network traffic is automatically collected and passed into Perch for analysis 
