#!/bin/bash
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

LOG="/var/lib/git_backup/temp/git_backup.log"

pull_repo() {
    echo "attempting pull of $1"
    pushd "/var/lib/git_backup/temp/$1"
    git pull --all && echo "pulled $1" >> $LOG
    popd
}
backup_repo() {
    echo "attempting clone of $1"
    # clone when new repo, otherwise pull
    (git clone "https://$1" "/var/lib/git_backup/temp/$1" && echo "cloned $1" >> $LOG ) || pull_repo $1
}

echo "Running git_backup.sh"
echo "Starting backup at $(date)" >> $LOG

while IFS="" read -r DIR || [ -n "$DIR" ]
do
    # only lines with content
    if [ -n "$DIR" ]; then
        # backup_repo $DIR
        echo $DIR
    fi
done \
    # only when GIT_USERNAME is given
    0<$([ -z ${GIT_USERNAME+x} ] && python3 /var/lib/git_backup/get_repos.py) \
    0</var/lib/git_backup/configs/other_repos.conf

echo "backup complete at $(date)" >> $LOG
echo >> $LOG

echo "all done"
echo

