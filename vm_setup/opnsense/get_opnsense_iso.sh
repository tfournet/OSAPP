#!/bin/sh

source /usr/local/osapp/osapp-vars.con


dnf -y install mkisofs

tmpdir="/tmp/opnsense_iso"
mkdir -p $tmpdir

dlfile=$tmpdir/opnsense_src.iso.bz2
OPNSense_URL="https://mirror.wdc1.us.leaseweb.net/opnsense/releases/21.1/OPNsense-21.1.r1-OpenSSL-dvd-amd64.iso.bz2"
OPNSense_SHA256="c6cfdd88227bb58c94634dca01e9108647a83278a4549291a4b772094342c81a"

# Download source ISO
echo "Downloading OPNSense Image from $OPNSense_URL"
if [ -f $dlfile ]; then
  echo "Already downloaded"
else
  curl -o $dlfile $OPNSense_URL
fi
Download_SHA256=$(sha256sum $dlfile | awk {'print $1'})

echo "Comparing Downloaded file checksum: $Download_SHA256"
echo "with Vendor-provided file checksum: $OPNSense_SHA256"

if [[ $Download_SHA256 != $OPNSense_SHA256 ]] ; then
  echo "ERROR: Unable to verify authenticity of downloaded OPNSense Package. Please check the variables file https://github.com/RaderSolutions/osapp/osapp-vars.conf for up to date URLs and SHA256sums"
  echo "Repair this and try again"
  exit 100
else 
  echo "Hashes match"
fi

echo "Extracting Image"

cd $tmpdir
bunzip2 $dlfile

mkdir -p iso_orig
mkdir -p iso_new

mount $dlfile ./iso_orig -o loop
cd iso_orig ; tar cf - . | (cd $tmpdir/iso_new; tar xfp -)

