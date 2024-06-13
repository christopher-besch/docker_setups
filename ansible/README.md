# Users
- `freeman`: user with passwordless sudo rights
- `apprun`: user in `docker` group, runs applications
- `root`: disabled

# Add new server (to Staging)
- add new host to inventory
- `ssh root@2a01:4f8:c17:dea8::1`
- `ansible-playbook -i staging.yml playbook/prepare_server.yml`
- `ansible-playbook -i staging.yml playbook/install_server.yml`
