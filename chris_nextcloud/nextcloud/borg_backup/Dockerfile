# can't be debian because it doesn't have borgbackup 1.2
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y bash borgbackup docker.io

# copy scripts
COPY ./borg_backup_init.sh ./borg_backup.sh /var/lib/borg_backup/

ENTRYPOINT ["bash", "/var/lib/borg_backup/borg_backup_init.sh"]

