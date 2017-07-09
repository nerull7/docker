FROM ubuntu:16.04
MAINTAINER Przemek Grondek <github@nerull7.info>

ENV OWNCLOUD_VER 10.0.2

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y nginx mysql-server php-fpm php-mysql php-gd php-json php-curl php-intl php-mcrypt php-imagick php-zip php-xml php-mbstring php-smbclient pwgen bzip2 gosu supervisor && \
    apt-get clean

# Make required catalogs
RUN mkdir -p /data/mysql \
             /data/owncloud \
             /data/owncloud/config \
             /data/owncloud/data \
             /data/nginx-log \
             /run/mysqld \
             /run/php

# Setup php
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini

# Setup nginx
RUN rm -rf /etc/nginx/sites-enabled/default
ADD owncloud /etc/nginx/sites-available/owncloud
RUN ln -s /etc/nginx/sites-available/owncloud  /etc/nginx/sites-enabled/owncloud
RUN sed -i "s/\/var\/log\/nginx/\/data\/nginx-log/g" /etc/nginx/nginx.conf

# Setup MySQL 
RUN sed -i "s/\/var\/lib\/mysql/\/data\/mysql/g" /etc/mysql/mysql.conf.d/mysqld.cnf
RUN mv /var/lib/mysql/* /data/mysql
RUN chown mysql:mysql /data/mysql /var/run/mysqld

# Setup owncloud
RUN rm -rf /var/www/*
ADD https://download.owncloud.org/community/owncloud-${OWNCLOUD_VER}.tar.bz2 /var/www
RUN tar xf /var/www/owncloud-${OWNCLOUD_VER}.tar.bz2 -C /var/www
RUN mv /var/www/owncloud/* /var/www
RUN rm /var/www/owncloud-${OWNCLOUD_VER}.tar.bz2 \
       /var/www/owncloud/.htaccess \
       /var/www/owncloud/.user.ini
RUN rmdir /var/www/owncloud
RUN mv /var/www/apps /data/owncloud && \
    mv /var/www/config /data/config
RUN ln -s /data/owncloud/config /var/www && \
    ln -s /data/owncloud/apps /var/www && \
    ln -s /data/owncloud/data /var/www
RUN chown -R www-data:www-data /data/owncloud /var/www

EXPOSE 80
VOLUME ["/data"]

COPY run.sh /
COPY supervisord.conf /

CMD ["/run.sh"]
