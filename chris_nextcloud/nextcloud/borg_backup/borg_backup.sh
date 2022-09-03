#!/bin/bash

###################################################
# to be run when the borg_backup container starts #
###################################################
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "running borg_backup"

function create_backup() {
    export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
    if ! borg check $BORG_REPO; then
        echo "ERROR: borg backup repo invalid"
        return
    fi

    echo "creating borg backup"
    borg create -error --compression ${BORG_COMPRESSION} "${BORG_REPO}::${BORG_PREFIX}_{now}" $NC_PATH

    echo "pruning borg repo"
    borg prune --keep-last 1 --keep-monthly 1 $BORG_REPO

    echo "compacting borg repo"
    borg compact $BORG_REPO
}

# wait for nextcloud to shut down gracefully
sleep 10
create_backup

