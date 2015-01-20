#!/bin/bash

/usr/bin/mysqld_safe &
sleep 10s

mysqladmin -u root password welcome
mysql -uroot -pwelcome -e "CREATE DATABASE ellie_admin;"
mysql -uroot -pwelcome -e "GRANT ALL PRIVILEGES ON ellie_admin.* TO 'admin'@'localhost' IDENTIFIED BY 'welcome'; FLUSH PRIVILEGES;"

mysqladmin -uroot -pwelcome shutdown
