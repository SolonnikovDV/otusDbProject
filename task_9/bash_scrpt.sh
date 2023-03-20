#!/bin/zsh

# download docker image from git 'https://github.com/aeuge/otus-mysql-docker'
# go to your local docker images directory
# run next:
gh repo clone aeuge/otus-mysql-docker

# go into 'aeuge/otus-mysql-docker' and run:
docker-compose up otusdb -d

# do to mysql:
docker-compose exec otusdb mysql -u root -p12345 otus

# enter to mysql:
mysql -u root -p12345 --port=3309 --protocol=tcp otus

# next steps into init.sql