#!/bin/bash
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# TODO: doesn't work
trap 'exit 0' INT TERM

apt-get update
apt-get install -y openssh-server
mkdir -p /run/sshd
chmod 0700 /root/.ssh
chmod 0600 /root/.ssh/authorized_keys
chown root:root /root/.ssh/authorized_keys

echo "starting sshd"
# needs to be in background for trap to work
/usr/sbin/sshd -D -o "Port 4200" -o "Port 6969" -o "PermitRootLogin yes" -o "PasswordAuthentication no"
