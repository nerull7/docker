#!/bin/bash

function first_run() {
  echo FIRST RUN

  mkdir -p /data/owncloud \
           /data/owncloud/config \
           /data/owncloud/data \
           /data/nginx-log

  cp -r /provision/owncloud/apps   /data/owncloud
  cp -r /provision/owncloud/config /data/owncloud
  cp -r /var/lib/mysql  /data

  chown -R www-data:www-data /data/owncloud /var/www
  chown -R mysql:mysql /data/mysql

  SQL_ROOT_PASSWORD="$(pwgen -s -1 16)"
  SQL_OWNCLOUD_PASSWORD="$(pwgen -s -1 16)"

  mysqld_safe &

  sleep 5

  mysql -u root -e "
	CREATE USER 'owncloud'@'localhost' IDENTIFIED BY '$SQL_OWNCLOUD_PASSWORD';
	CREATE DATABASE owncloud;
	GRANT ALL PRIVILEGES ON owncloud . * TO owncloud@localhost;
	FLUSH PRIVILEGES;"
  mysqladmin -u root password $SQL_ROOT_PASSWORD

  cd /var/www
  gosu www-data php occ maintenance:install \
   --database "mysql" --database-name "owncloud" \
   --database-user "owncloud" --database-pass "$SQL_OWNCLOUD_PASSWORD" \
   --admin-user "admin" --admin-pass "password"

  killall mysqld

  touch /data/.provisioned

  sleep 10
}

if [ ! -f "/data/.provisioned" ];
then
  first_run
fi
supervisord -n -c /supervisord.conf
