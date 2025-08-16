# THIS REPO MOVED TO [codeberg.org/christopher-besch/docker_setups](https://codeberg.org/christopher-besch/docker_setups)


# Docker Setups
Feel free to use these setups as inspiration for your own servers (i.e. create a fork).
If you have any questions or ideas, open an issue or message me at `mail@chris.besch.com`.

Run `ansible-galaxy collection install community.docker` on host.

# Users
- `freeman`: user with passwordless sudo rights
- `apprun`: user in `docker` group, runs applications
- `root`: disabled

## Install Procedure Hetzner
- Create new server
- add new host to inventory to hetzner group
- `ssh root@[server ip]`
- `ansible-playbook -i production.yml playbook/prepare_server.yml`
- `ansible-playbook -i production.yml playbook/install_server.yml`
- `ansible-playbook -i production.yml playbook/update_server.yml`
- Possibly run `ansible-playbook -i production.yml playbook/down_container.yml` if you don't have a proper backup to load
- create backup tar on old server, copy over untar in `/home/apprun/app` using `sudo tar --same-owner -xvf file.tar`
- `ansible-playbook -i production.yml playbook/install_container.yml`

## Install Procedure Raspberry Pi
- install raspbery pi imager
- install Raspberry Pi OS Lite with
    - username: pi
    - password: raspberry
    - no wifi
    - locale: timezone Etc/UTC, keyboard: gb
    - ssh settings: chris.pub key
- add new host to inventory to raspberry group
- `ssh pi@[server ip]`
- `ansible-playbook -i production.yml playbook/prepare_server.yml`
- `ansible-playbook -i production.yml playbook/install_server.yml`
- `ansible-playbook -i production.yml playbook/update_server.yml`
- Possibly run `ansible-playbook -i production.yml playbook/down_container.yml` if you don't have a proper backup to load
- create backup tar on old server, copy over untar in `/home/apprun/app` using `sudo tar --same-owner -xvf file.tar`
- `ansible-playbook -i production.yml playbook/install_container.yml`

## Maintenance Procedure
- update https://github.com/ankitects/anki/tree/main/docs/syncserver: `sudo docker build --no-cache --build-arg ANKI_VERSION=25.02 -t chrisbesch/anki_sync_server:25.02 . && sudo docker push chrisbesch/anki_sync_server:25.02`
- check `last`
- check `df -h`
- `ansible-playbook -i production.yml playbook/down_container.yml -l amd64hetzner10`
- enable external hetzner box access and ssh
- `sudo tar -cvf /home/apprun/box/borg/backup_2024_08_05.tar /home/apprun/app`
- `rsync --dry-run --delete --exclude selchris_music --exclude jonas_music -avP u370909@u370909.your-storagebox.de:/home/nextcloud_lfs/ /home/chris/files/backup/server/nextcloud_lfs/` (remove `--dry-run`)
- `rsync --dry-run --delete -avP u370909@u370909.your-storagebox.de:/home/photoprism_data/ /home/chris/files/backup/server/photoprism_data/` (remove `--dry-run`)
- `rsync --dry-run --delete -avP u370909@u370909.your-storagebox.de:/home/forgejo_box/ /home/chris/files/backup/server/forgejo_box/` (remove `--dry-run`)
- bump versions & push changes to github
- `rsync --dry-run -avP u370909@u370909.your-storagebox.de:/home/docker_backup/backup_2024_08_05.tar /home/chris/files/backup/server/hetzner03_backup_2024_08_05.tar` (remove `--dry-run`)
- maybe delete old backup on server and locally
- check archive integrity `sha1sum backup_2024_08_05.tar`
- disable external box access and ssh
- `ansible-playbook -i production.yml playbook/update_server.yml -l amd64hetzner10`
- `ansible-playbook -i production.yml playbook/pull_container.yml -l amd64hetzner10`
- `docker exec -ti --user www-data NCFrontend /var/www/html/occ upgrade`
- `docker exec -ti --user www-data NCFrontend /var/www/html/occ db:add-missing-indices`
- `docker exec -ti --user www-data NCFrontend /var/www/html/occ maintenance:repair --include-expensive`
- check https://nextcloud.chris-besch.com/settings/admin/overview
- check https://nextcloud.chris-besch.com/settings/admin
- update apps at https://nextcloud.chris-besch.com/settings/apps/installed
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

### Attach to Minecraft Console
- `docker attach Minecraft`
- Ctrl-p Ctrl-q to detach

### Node-Red
- configure ansible/playbook/roles/docker_node_red/files/configuration.yaml mqtt server
- `mkdir /home/apprun/app/node_red/node_red_data`
- `sudo chown 1000:1000 /home/apprun/app/node_red/node_red_data`
- set password: https://nodered.org/docs/user-guide/runtime/securing-node-red#http-node-security
- set mosquitto passwords for all consumers in ansible/playbook/roles/docker_node_red/files/mosquitto_passwords.txt
