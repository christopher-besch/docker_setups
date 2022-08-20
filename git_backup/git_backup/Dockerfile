FROM debian:latest

RUN apt-get update && apt-get install -y cron bash git python3 python3-pip
RUN pip3 install PyGithub

RUN git config --global pull.rebase true

COPY ./crontab /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab && crontab /etc/cron.d/crontab

COPY ./git_backup.sh /var/lib/git_backup/git_backup.sh
COPY ./get_repos.py /var/lib/git_backup/get_repos.py

# ENTRYPOINT ["cron", "-f"]
ENTRYPOINT ["bash", "/var/lib/git_backup/git_backup.sh"]

