FROM ubuntu:latest

RUN apt-get update && apt-get install -y cron bash git python3 python3-pip borgbackup
RUN pip3 install PyGithub

# configure git
RUN git config --global pull.rebase true
RUN git config --global credential.helper store

# configure cron
COPY ./crontab /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab && crontab /etc/cron.d/crontab

# copy scripts
COPY ./get_repos.py ./git_backup_init.sh ./git_backup.sh /var/lib/git_backup/

ENTRYPOINT ["bash", "/var/lib/git_backup/git_backup_init.sh"]

