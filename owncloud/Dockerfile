FROM ubuntu:16.04
MAINTAINER Przemek Grondek <github@nerull7.info>

ENV OWNCLOUD_VER 10.0.2

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y nginx mysql-server php-fpm php-mysql php-gd php-json php-curl php-intl php-mcrypt php-imagick php-zip php-xml php-mbstring php-smbclient pwgen bzip2  gosu supervisor cron && \
    apt-get clean

# Make required catalogs
RUN mkdir -p /run/mysqld \
             /run/php

# Setup php
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;env\[HOSTNAME\] = $HOSTNAME/env\[HOSTNAME\] = $HOSTNAME/g" /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -i "s/;env\[PATH\] = \/usr\/local\/bin:\/usr\/bin:\/bin/env\[PATH\] = \/usr\/local\/bin:\/usr\/bin:\/bin/g" /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -i "s/;env\[TMP\] = \/tmp/env\[TMP\] = \/tmp/g" /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -i "s/;env\[TMPDIR\] = \/tmp/env\[TMPDIR\] = \/tmp/g" /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -i "s/;env\[TEMP\] = \/tmp/env\[TEMP\] = \/tmp/g" /etc/php/7.0/fpm/pool.d/www.conf

# Setup nginx
RUN rm -rf /etc/nginx/sites-enabled/default
ADD owncloud /etc/nginx/sites-available/owncloud
RUN ln -s /etc/nginx/sites-available/owncloud  /etc/nginx/sites-enabled/owncloud
RUN sed -i "s/\/var\/log\/nginx/\/data\/nginx-log/g" /etc/nginx/nginx.conf

# Setup MySQL 
RUN sed -i "s/\/var\/lib\/mysql/\/data\/mysql/g" /etc/mysql/mysql.conf.d/mysqld.cnf
RUN chown mysql:mysql /var/run/mysqld

# Setup owncloud
RUN rm -rf /var/www/*
ADD https://download.owncloud.org/community/owncloud-${OWNCLOUD_VER}.tar.bz2 /var/www
RUN tar xf /var/www/owncloud-${OWNCLOUD_VER}.tar.bz2 -C /var/www
RUN mv /var/www/owncloud/* /var/www
RUN rm /var/www/owncloud-${OWNCLOUD_VER}.tar.bz2 \
       /var/www/owncloud/.htaccess \
       /var/www/owncloud/.user.ini
RUN rmdir /var/www/owncloud
RUN echo "*/15 *  * * *   www-data php -f /var/www/cron.php" >> /etc/crontab

# Provision data
RUN mkdir -p /provision/owncloud
RUN cp -r /var/www/apps   /provision/owncloud
RUN cp -r /var/www/config /provision/owncloud
RUN rm -rf /var/www/apps \
           /var/www/config
RUN ln -s /data/owncloud/config /var/www
RUN ln -s /data/owncloud/apps /var/www
RUN ln -s /data/owncloud/data /var/www

EXPOSE 80
VOLUME ["/data"]

COPY run.sh /
COPY supervisord.conf /

CMD ["/run.sh"]
