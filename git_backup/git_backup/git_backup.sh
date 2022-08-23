#!/bin/bash

##############################################
# to be run every time a backup gets created #
##############################################
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

GIT_BACKUP_DIR="/var/lib/git_backup"
TEMP_DIR="$GIT_BACKUP_DIR/temp"
BORG_REPO="$GIT_BACKUP_DIR/repo"
CONFIGS_DIR="$GIT_BACKUP_DIR/configs"
# used to clone repos into ->
# makes time where the actual repo target dir is present but not properly cloned yet as short as possible ->
# crashes don't create zombie dirs that can't be git pulled or cloned
CLONE_TARGET="$TEMP_DIR/clone_target"
LOG="$TEMP_DIR/git_backup.log"

clone_repo() {
    echo "cloning $1"
    rm -rf $CLONE_TARGET

    if git clone "https://$1" $CLONE_TARGET --recurse; then
        REPO_DIR="$TEMP_DIR/$1"
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
    pushd "$TEMP_DIR/$1" >/dev/null

    if ! git remote update; then
        echo "error fetching upstream of $1" >> $LOG
    fi
    # check if pull is actually necessary -> cleaner logs
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
    if [ -d "$TEMP_DIR/$1" ]; then
        pull_repo $1
    else
        clone_repo $1
    fi
}

backup_all_repos() {
    echo "starting backup at $(date)" >> $LOG
    while IFS="" read -r CUR_DIR || [ -n "$CUR_DIR" ]; do
        # only lines with content
        if [ -n "$CUR_DIR" ]; then
            backup_repo $CUR_DIR
        fi
    # only load all repos when GITHUB_USERNAME given
    done < <(cat \
        $CONFIGS_DIR/other_repos.conf \
        <([ -z ${GITHUB_USERNAME+x} ] || \
        python3 $GIT_BACKUP_DIR/get_repos.py))
    echo "backup complete at $(date)" >> $LOG
}

create_borg_backup() {
    export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
    if ! borg check $BORG_REPO; then
        echo "borg backup repo invalid" >> $LOG
        return
    fi
    echo >> $LOG

    echo "creating borg backup"
    borg create -error --compression zstd,22 "${BORG_REPO}::git_backup_{now}" $TEMP_DIR

    echo "pruning borg repo"
    borg prune --keep-last 1 --keep-monthly 1 $BORG_REPO

    echo "compacting borg repo"
    borg compact $BORG_REPO
}

echo "running git_backup.sh"

backup_all_repos
create_borg_backup

echo "all done"
echo

