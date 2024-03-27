# Docker Setups
Feel free to use these setups as inspiration for your own servers (i.e. create a fork).
If you have any questions or ideas, open an issue or message me at `mail@chris.besch.com`.


## Running Docker Compose on hetzner03
```
NAME                STATUS              CONFIG FILES
cron                running(1)          /home/chris/docker_setups/cron/docker-compose.yaml
fireflyiii          running(4)          /home/chris/docker_setups/fireflyiii/docker-compose.yaml
jellyfin            running(1)          /home/chris/docker_setups/jellyfin/docker-compose.yaml
minecraft_java      running(4)          /home/chris/docker_setups/minecraft_java/docker-compose.yaml
nextcloud           running(4)          /home/chris/docker_setups/nextcloud/docker-compose.yaml
nginx               running(2)          /home/chris/docker_setups/nginx/docker-compose.yaml
photoprism          running(3)          /home/chris/docker_setups/photoprism/docker-compose.yaml
tandoor             running(3)          /home/chris/docker_setups/tandoor/docker-compose.yaml
```


## Install Procedure
1. Create new server
2. login as root
3. `adduser chris`
4. `usermod -aG sudo chris`
5. add ssh pub key to `/home/chris/.ssh/authorized_keys`
6. login as chris
7. `sudo apt update && sudo apt dist-upgrade -y`
8. `sudo timedatectl set-timezone Europe/Berlin`
9. reboot
10. `sudo apt install tree git cifs-utils jq -y`
11. `git clone https://github.com/christopher-besch/configs .custom_configs`
12. `~/.custom_configs/install.sh server`
13. [install docker](https://docs.docker.com/engine/install/debian)
14. `sudo usermod -aG docker chris`
15. `sudo mkdir /mnt/box03`
16. `sudo chown chris /mnt/box03`
17. enable only samba support in storage box
18. add this line to `/etc/fstab` (get 1000 from `id chris` and `id www-data`, you need to run the nextcloud container first)
    ```
    //u370909.your-storagebox.de/backup/docker_backup /mnt/box03/docker_backup cifs iocharset=utf8,rw,credentials=/etc/box03-credentials.txt,uid=1000,gid=1000,file_mode=0660,dir_mode=0770,_netdev 0 0
    //u370909.your-storagebox.de/backup/nextcloud_lfs /mnt/box03/nextcloud_lfs cifs iocharset=utf8,rw,credentials=/etc/box03-credentials.txt,uid=33,gid=33,file_mode=0660,dir_mode=0770,_netdev 0 0
    ```
19. add file `/etc/box03-credentials.txt` owned by root
    ```
    username=<username>
    password=<password>
    ```
20. `sudo chown root /etc/box03-credentials.txt`
21. `sudo chmod 0600 /etc/box03-credentials.txt`
22. `git clone https://github.com/christopher-besch/docker_setups` in `~`
23. `scp /home/chris/files/docker_envs/hetzner01/*.env chris@49.13.65.242:/home/chris` on host
24. move .env in correct locations
25. `ln -s /mnt/box03/nextcloud_lfs/ nextcloud_lfs`
26. `ln -s /mnt/box03/docker_backup/ docker_backup`
27. create backup tar on old server, copy over untar in `~/docker_data` using `sudo tar --same-owner -xvf file.tar`
28. DON'T FORGET THE TRUSTED PROXIES IN THE FIREFLYIII AND NEXTCLOUD DOCKER-COMPOSE.YAML AS WELL AS IN THE NEXTCLOUD CONFIG.PHP (`/home/chris/docker_data/nextcloud/nc_data/config/config.php`)!
29. start container


## Maintenance Procedure
1. bump firefly, nextcloud, photoprism, tandoor, uptime-kuma versions to newest minor patch & push changes to github
2. check `last`
3. check `df -h`
4. shut down all docker compose instances
5. `sudo tar -cvf backup_2024_02_03.tar /home/chris/docker_data` in `/mnt/box03/docker_backup`
6. check with `rsync --dry-run --delete --exclude selchris_music --exclude jonas_music -avP chris@nextcloud.chris-besch.com:/home/chris/nextcloud_lfs/ /home/chris/files/backup/server/nextcloud_lfs/`
7. `rsync --delete --exclude selchris_music --exclude jonas_music -avP chris@nextcloud.chris-besch.com:/home/chris/nextcloud_lfs/ /home/chris/files/backup/server/nextcloud_lfs/`
8. `cp /home/chris/files/backup/server/hetzner03_backup_2023_12_13.tar /home/chris/files/backup/server/hetzner03_backup_2023_12_27.tar`
9. `rsync -avP chris@nextcloud.chris-besch.com:/mnt/box03/docker_backup/backup_2023_12_27.tar /home/chris/files/backup/server/hetzner03_backup_2023_12_27.tar`

    or enable external box access and `rsync -avP u370909@u370909.your-storagebox.de:/home/docker_backup/backup_2023_12_27.tar /home/chris/files/backup/server/hetzner03_backup_2023_12_27.tar`
10. check archive integrity `sha256sum backup_2023_09_06.tar`
11. `sudo apt update && sudo apt dist-upgrade -y`
13. `sudo reboot`
13. `git pull` in `/home/chris/docker_setups`
14. `docker compose pull && docker compose up -d && docker compose logs --follow` for all services and check they're running
15. `docker exec -ti --user www-data NCFrontend_chris_nextcloud /var/www/html/occ upgrade`
16. `docker exec -ti --user www-data NCFrontend_chris_nextcloud /var/www/html/occ db:add-missing-indices`
17. check https://nextcloud.chris-besch.com/settings/admin/overview
18. check https://nextcloud.chris-besch.com/settings/admin
19. update apps at https://nextcloud.chris-besch.com/settings/apps
20. `docker system prune -a`
21. check `df -h`
22. create backup on external hard drive


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

