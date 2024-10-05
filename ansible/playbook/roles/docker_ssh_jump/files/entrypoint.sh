#!/bin/bash
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# install sshd here and not in a custom image to allow for easier updating
apt-get update
apt-get install -y openssh-server
mkdir -p /run/sshd
chmod 0700 /root/.ssh
# TODO: remove this line
chmod 0600 /root/.ssh/authorized_keys
# TODO: remove this line
chown root:root /root/.ssh/authorized_keys

echo "starting sshd"
# Without "GatewayPorts yes" the problem is that the port is opened on the remote docker container with sshd on localhost (127.0.0.11)
# nginx is looking for 172.20.0.11
#
# So use GatewayPorts to bind to the wildcard address
/usr/sbin/sshd -D -o "Port 42069" -o "PermitRootLogin yes" -o "PasswordAuthentication no" -o "GatewayPorts yes"

# use with:
# ssh -nNT -R 443:localhost:42000 -p 42069 -i ~/.ssh/chris root@node-red.chris-besch.com
#
