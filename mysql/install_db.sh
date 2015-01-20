#!/bin/bash

/usr/bin/mysqld_safe &
sleep 10s

mysqladmin -u root password welcome
mysql -uroot -pwelcome -e "CREATE DATABASE ellie_admin;"
mysql -uroot -pwelcome -e "GRANT ALL PRIVILEGES ON ellie_admin.* TO 'admin'@'localhost' IDENTIFIED BY 'welcome'; FLUSH PRIVILEGES;"

echo "cd into app"
cd /app

echo "run migration script"
php artisan migrate

echo "seed the db"
php artisan db:seed

mysqladmin -uroot -pwelcome shutdown
