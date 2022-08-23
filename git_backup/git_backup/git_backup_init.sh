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

echo "init at $(date)" >> $LOG

# call script when receiving SIGHUP
# set -e exits script after trap
set +e
trap 'bash /var/lib/git_backup/git_backup.sh || echo "trap script failed"' HUP

# await SIGHUP
while :; do
    sleep 10 & wait ${!}
done

