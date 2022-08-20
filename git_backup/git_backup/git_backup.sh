#!/bin/bash

##############################################
# to be run every time a backup gets created #
##############################################
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
LOG="/var/lib/git_backup/temp/git_backup.log"
# used to clone repos into ->
# makes time where the actual repo target dir is present but not properly cloned yet as short as possible ->
# crashes don't create zombie dirs that can't be git pulled or cloned
CLONE_TARGET="/var/lib/git_backup/temp/clone_target"

clone_repo() {
    echo "cloning $1"
    rm -rf $CLONE_TARGET

    if git clone "https://$1" $CLONE_TARGET --recurse; then
        REPO_DIR="/var/lib/git_backup/temp/$1"
        mkdir -p $REPO_DIR
        mv -T $CLONE_TARGET $REPO_DIR
        echo "cloned $1" >> $LOG
    else
        echo "Error: failed to clone $1"
        echo "error cloning $1" >> $LOG
    fi
}
pull_repo() {
    echo "pulling $1 if required"
    pushd "/var/lib/git_backup/temp/$1" >/dev/null

    # check if pull is necessary -> cleaner logs
    git remote update
    if git status -uno | grep -P '^Your branch is behind '; then
        echo "pulling $1"
        if git pull --all; then
            echo "pulled $1" >> $LOG
        else
            echo "Error: failed to pull $1"
            echo "error pulling $1" >> $LOG
        fi
    else
        echo "pull not required"
    fi

    popd >/dev/null
}
backup_repo() {
    if [ -d "/var/lib/git_backup/temp/$1" ]; then
        pull_repo $1
    else
        clone_repo $1
    fi
}

echo "running git_backup.sh"
echo "starting backup at $(date)" >> $LOG

while IFS="" read -r CUR_DIR || [ -n "$CUR_DIR" ]
do
    # only lines with content
    if [ -n "$CUR_DIR" ]; then
        backup_repo $CUR_DIR
    fi
# only load all repos when GITHUB_USERNAME given
done < <(cat \
    /var/lib/git_backup/configs/other_repos.conf \
    <([ -z ${GITHUB_USERNAME+x} ] || \
    python3 /var/lib/git_backup/get_repos.py))

echo "backup complete at $(date)" >> $LOG
echo >> $LOG

echo "all done"
echo

