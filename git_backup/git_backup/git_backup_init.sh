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

# redirect output to stdout and stderr of cron process -> usable docker logs
echo "$CRON_TIME" '/bin/bash /var/lib/git_backup/git_backup.sh > /proc/$(cat /var/run/crond.pid)/fd/1 2>/proc/$(cat /var/run/crond.pid)/fd/2' > /etc/cron.d/crontab
chmod 0644 /etc/cron.d/crontab
crontab /etc/cron.d/crontab

echo "starting cron at $(date)" >> $LOG
# start the action
cron -f

# for debugging
# bash /var/lib/git_backup/git_backup.sh

