# chris-nextcloud

### Requirements
`sudo docker network create net`

### in `/etc/fstab`
`https://schiffchen.selfhost.eu/remote.php/webdav/ /media/chris_nextcloud davfs _netdev,user,uid=1000,gid=1000 0 0`

### in `/etc/davfs2/secrets`
`/media/chris_nextcloud chris PASSWD`

### Commands
`sudo docker exec -ti --user www-data nextcloud_NCFrontend_1 /var/www/html/occ files:scan --all`

