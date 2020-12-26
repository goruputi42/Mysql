#!/usr/bin/env bash

echo ">>> Installing MySQL Server"
table_create='CREATE TABLE `opstreeDB`.`contact` ( `id` INT NOT NULL AUTO_INCREMENT, `name` VARCHAR(20) NULL, `position` VARCHAR(100) NULL, `company` VARCHAR(50) NULL, `joining_date` DATE NULL, PRIMARY KEY (`id`));'
[[ -z "$1" ]] && { echo "!!! MySQL root password not set. Check the Vagrant file."; exit 1; }

mysql_package=mysql-server

# Install MySQL without password prompt
# Set username and password to 'root'
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $1"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $1"

# Install MySQL Server
# -qq implies -y --force-yes
sudo apt-get install -qq $mysql_package
echo ">>>>>> install done"
sudo mysql -uroot -p$1 << eof1
CREATE DATABASE opstreeDB;
show databases;
USE opstreeDB;
$table_create
eof1
echo ">>>>>> db is created with table"
sudo mysqldump -uroot -p$1 opstreeDB > /home/ubuntu/opstreeDB.sql
sleep 15
echo "<<<<<<<<<<<<<< second time login"
sudo mysql -uroot -p$1 << eof2
DROP DATABASE opstreeDB;
eof2
sudo mysql -uroot -p$1 << eof3
CREATE DATABASE opstreeDB;
eof3
echo "<last import....>"
sudo mysql -uroot -p$1 opstreeDB < /home/ubuntu/opstreeDB.sql
sleep 15