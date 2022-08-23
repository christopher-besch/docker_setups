# can't be debian because it doesn't have borgbackup 1.2
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y bash git python3 python3-pip borgbackup && \
    pip3 install PyGithub

# configure git
RUN git config --global pull.rebase true && \
    git config --global credential.helper store && \
    git config --global --add safe.directory /var/lib/git_backup/temp

# copy scripts
COPY ./get_repos.py ./git_backup_init.sh ./git_backup.sh /var/lib/git_backup/

ENTRYPOINT ["bash", "/var/lib/git_backup/git_backup_init.sh"]

