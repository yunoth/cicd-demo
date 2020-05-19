#!/bin/bash
sudo yum install -y docker
sudo service docker start
docker run --name mysql -e MYSQL_ROOT_PASSWORD=callicoder -d -p 3066:3066 mysql:5.7
sleep 10
docker exec -i mysql mysql -uroot -pcallicoder  <<< "create database notes_app;"

