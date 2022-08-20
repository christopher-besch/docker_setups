#!/bin/bash

###################################
# entry point of docker container #
###################################
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
LOG="/var/lib/git_backup/temp/git_backup.log"

echo "running git_backup_init.sh"

# TODO: allow other git servers
if [ ! -z ${GITHUB_USERNAME+x} ]; then
    cat <<EOF > /root/.git-credentials
https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com
EOF
fi

echo "starting cron at $(date)" >> $LOG
# start the action
# cron -f

bash /var/lib/git_backup/git_backup.sh
