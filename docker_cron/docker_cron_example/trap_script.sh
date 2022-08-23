#!/bin/bash

############################################
# await SIGHUP and then run the actual job #
############################################
trap 'bash /actual_job.sh' HUP
while :; do
    sleep 10 & wait ${!}
done

