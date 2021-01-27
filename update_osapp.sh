#!/bin/sh

source /etc/osapp/osapp-vars.conf


rm -rf /tmp/osapp
cd /tmp
git clone https://github.com/tfournet/osapp \
    && rm -rf /usr/local/osapp \
    && mv -f /tmp/osapp /usr/local

echo "Updated"

