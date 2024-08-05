# Docker Setups
Feel free to use these setups as inspiration for your own servers (i.e. create a fork).
If you have any questions or ideas, open an issue or message me at `mail@chris.besch.com`.

# Users
- `freeman`: user with passwordless sudo rights
- `apprun`: user in `docker` group, runs applications
- `root`: disabled

## Install Procedure
- Create new server
- add new host to inventory
- `ssh root@[server ip]`
- `ansible-playbook -i production.yml playbook/prepare_server.yml`
- `ansible-playbook -i production.yml playbook/install_server.yml`
- `ansible-playbook -i production.yml playbook/update_server.yml`
- Possibly run `ansible-playbook -i production.yml playbook/down_container.yml` if you don't have a proper backup to load
- create backup tar on old server, copy over untar in `/home/apprun/app` using `sudo tar --same-owner -xvf file.tar`
- `ansible-playbook -i production.yml playbook/install_container.yml`

## Maintenance Procedure
- `cp /home/chris/files/backup/server/hetzner03_backup_2024_03_27.tar /home/chris/files/backup/server/hetzner03_backup_2024_08_05.tar`
- check `last`
- check `df -h`
- `ansible-playbook -i production.yml playbook/down_container.yml`
- bump firefly, nextcloud, photoprism, tandoor, uptime-kuma versions to newest minor patch & push changes to github
- `sudo tar -cvf /home/apprun/box/borg/backup_2024_08_05.tar /home/apprun/app`
- enable external box access and ssh
- `rsync --dry-run --delete --exclude selchris_music --exclude jonas_music -avP u370909@u370909.your-storagebox.de:/home/nextcloud_lfs/ /home/chris/files/backup/server/nextcloud_lfs/` (remove `--dry-run`)
- `rsync --dry-run -avP u370909@u370909.your-storagebox.de:/home/docker_backup/backup_2024_08_05.tar /home/chris/files/backup/server/hetzner03_backup_2024_08_05.tar` (remove `--dry-run`)
- maybe delete old backup on server and locally
- disable external box access and ssh
- check archive integrity `sha256sum backup_2024_08_05.tar`
- `ansible-playbook -i production.yml playbook/update_server.yml`
- `ansible-playbook -i production.yml playbook/pull_container.yml`
- `docker exec -ti --user www-data NCFrontend /var/www/html/occ upgrade`
- `docker exec -ti --user www-data NCFrontend /var/www/html/occ db:add-missing-indices`
- check https://nextcloud.chris-besch.com/settings/admin/overview
- check https://nextcloud.chris-besch.com/settings/admin
- update apps at https://nextcloud.chris-besch.com/settings/apps
- `docker system prune -a`
- check `df -h`
- create backup on external hard drive

# Upgrade Postgresql for Tandoor
1. `sudo cp -r /home/chris/docker_data/tandoor/ /home/chris/tandoor.bak`
2. `docker exec -t TDDatabase_chris_tandoor pg_dumpall -U tandoor > /home/chris/dump`
3. shut down docker containers
4. remove other container from docker-compose.yaml, update to new postgres version and mount `/home/chris/dump` to `/dump`
5. `sudo rm -r /home/chris/docker_data/tandoor/td_postgres`
6. start container
7. `docker exec -t -i TDDatabase_chris_tandoor /bin/sh` and then `psql -U tandoor tandoordb < /dump` in container with 
9. `cp /home/chris/tandoor.bak/td_postgres/{pg_hba.conf,postgresql.conf} /home/chris/docker_data/tandoor/td_postgres/`
10. stop containers
11. reset docker-compose.yaml and set new postgres/tandoor version
12. start container

- from [here](https://openqa-bites.github.io/posts/2023/2023-11-23-upgrade_a_postgresql_container_to_a_new_major_version)

# Resolve Locked Nextcloud Files
1. `docker exec -ti --user www-data NCFrontend_chris_nextcloud /var/www/html/occ maintenance:mode --on`
2. `docker exec -it NCDatabase_chris_nextcloud bash`
3. `mariadb -u nextcloud -p -D NC -e "DELETE FROM oc_file_locks WHERE 1"`
4. `docker exec -ti --user www-data NCFrontend_chris_nextcloud /var/www/html/occ maintenance:mode --off`
- https://zedt.eu/tech/linux/how-to-clean-up-nextcloud-stale-locked-files/


### Other Nextcloud Commands
- `sudo docker exec -ti --user www-data NCFrontend_chris_nextcloud /var/www/html/occ files:scan --all`
- `sudo docker exec -ti --user www-data NCFrontend_chris_nextcloud /var/www/html/occ trashbin:cleanup --all-users`
