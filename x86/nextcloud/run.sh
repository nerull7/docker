#!/bin/bash

function first_run() {
  echo FIRST RUN

  mkdir -p /data/nextcloud \
           /data/nextcloud/config \
           /data/nextcloud/data \
           /data/nginx-log

  cp -r /provision/nextcloud/apps   /data/nextcloud
  cp -r /provision/nextcloud/config /data/nextcloud
  cp -r /var/lib/mysql  /data

  chown -R www-data:www-data /data/nextcloud /var/www
  chown -R mysql:mysql /data/mysql

  SQL_ROOT_PASSWORD="$(pwgen -s -1 16)"
  SQL_NEXTCLOUD_PASSWORD="$(pwgen -s -1 16)"

  mysqld_safe &

  sleep 5

  mysql -u root -e "
	CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '$SQL_NEXTCLOUD_PASSWORD';
	CREATE DATABASE nextcloud;
	GRANT ALL PRIVILEGES ON nextcloud . * TO nextcloud@localhost;
	FLUSH PRIVILEGES;"
  mysqladmin -u root password $SQL_ROOT_PASSWORD

  cd /var/www
  gosu www-data php occ maintenance:install \
   --database "mysql" --database-name "nextcloud" \
   --database-user "nextcloud" --database-pass "$SQL_NEXTCLOUD_PASSWORD" \
   --admin-user "admin" --admin-pass "password"
  gosu www-data php occ background:cron

  killall mysqld

  touch /data/.provisioned

  sleep 10
}

if [ ! -f "/data/.provisioned" ];
then
  first_run
fi
supervisord -n -c /supervisord.conf
