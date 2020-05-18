#!/bin/bash
sudo yum install docker
sudo service docker start
docker run --name mysql -e MYSQL_ROOT_PASSWORD=callicoder -d -p 3066:3066 mysql:tag
