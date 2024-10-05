#!/bin/bash
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# install ssh here and not in a custom image to allow for easier updating
apt-get update
apt-get install -y ssh
chmod 0700 /root/.ssh
# TODO: remove this line
chmod 0600 /root/.ssh/ssh_jump_key
# TODO: remove this line
chown root:root /root/.ssh/ssh_jump_key

echo "starting ssh"
# attach the local nginx container to the ssh tunnel
#                     <- port on remote server (nginx on the hetzner server is connecting to this)
#                                   <- port of frontend running on raspberry pi
#            <- port of ssh tunnel
ssh -vnNT -p 42069 -R 42000:NodeRed:1880 -R 42001:NginxFrontendTest:80 -i /root/.ssh/ssh_jump_key root@node-red.chris-besch.com
