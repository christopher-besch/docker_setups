FROM debian:latest

RUN apt-get update && apt-get install -y cron bash
COPY ./crontab /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab && crontab /etc/cron.d/crontab

COPY ./git_backup.sh /var/lib/git_backup/git_backup.sh
RUN chmod 0744 /var/lib/git_backup/git_backup.sh

ENTRYPOINT ["cron", "-f"]

