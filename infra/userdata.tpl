#!/bin/bash
# Description: Set up MySQL Community Release 5.7

# Get the repo RPM and install it.
wget http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm 
yum -y install ./mysql57-community-release-el7-7.noarch.rpm 

# Install the server and start it
yum -y install mysql-community-server 
systemctl start mysqld 

# Get the temporary password
temp_password=$(grep password /var/log/mysqld.log | awk '{print $NF}')

# Set up a batch file with the SQL commands
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Callicoder!23'; flush privileges;" > reset_pass.sql
echo "create database notes_app; GRANT ALL ON notes_app.* TO root@'%' IDENTIFIED BY 'Callicoder!23'" > grants.sql

# Log in to the server with the temporary password, and pass the SQL file to it.
mysql -u root --password="$temp_password" --connect-expired-password < reset_pass.sql

mysql -u root -p'Callicoder!23' < grants.sql