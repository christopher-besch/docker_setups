#!/bin/bash
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

ssh-keygen
cat ~/.ssh/jonas.pub
sudo mkdir -p /run/sshd
