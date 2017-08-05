FROM arm32v7/debian:stretch
MAINTAINER Przemek Grondek <github@nerull7.info>

ENV NEXTCLOUD_VER 12.0.0

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y nginx mysql-server php-fpm php-mysql php-gd php-json php-curl php-intl php-mcrypt php-imagick php-zip php-xml php-mbstring php-smbclient pwgen bzip2  gosu supervisor cron && \
    apt-get clean

# Make required catalogs
RUN mkdir -p /run/mysqld \
             /run/php

# Setup php
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini && \
    sed -i "s/;env\[HOSTNAME\] = $HOSTNAME/env\[HOSTNAME\] = $HOSTNAME/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s/;env\[PATH\] = \/usr\/local\/bin:\/usr\/bin:\/bin/env\[PATH\] = \/usr\/local\/bin:\/usr\/bin:\/bin/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s/;env\[TMP\] = \/tmp/env\[TMP\] = \/tmp/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s/;env\[TMPDIR\] = \/tmp/env\[TMPDIR\] = \/tmp/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s/;env\[TEMP\] = \/tmp/env\[TEMP\] = \/tmp/g" /etc/php/7.0/fpm/pool.d/www.conf

# Setup nginx
ADD nextcloud /etc/nginx/sites-available/nextcloud
RUN rm -rf /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/nextcloud  /etc/nginx/sites-enabled/nextcloud && \
    sed -i "s/\/var\/log\/nginx/\/data\/nginx-log/g" /etc/nginx/nginx.conf

# Setup MySQL 
RUN sed -i "s/\/var\/lib\/mysql/\/data\/mysql/g" /etc/mysql/mariadb.conf.d/50-server.cnf && \
    chown mysql:mysql /var/run/mysqld

# Setup nextcloud
RUN rm -rf /var/www/*
ADD https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VER}.tar.bz2 /var/www
RUN mv /var/www/nextcloud/* \
       /var/www/nextcloud/.htaccess \
       /var/www/nextcloud/.user.ini \
       /var/www && \
    rmdir /var/www/nextcloud && \
    echo "*/15 *  * * *   www-data php -f /var/www/cron.php" >> /etc/crontab

# Provision data
RUN mkdir -p /provision/nextcloud && \
    cp -r /var/www/apps   /provision/nextcloud && \
    cp -r /var/www/config /provision/nextcloud && \
    rm -rf /var/www/apps \
           /var/www/config && \
    ln -s /data/nextcloud/config /var/www && \
    ln -s /data/nextcloud/apps /var/www && \
    ln -s /data/nextcloud/data /var/www

EXPOSE 80
VOLUME ["/data"]

COPY run.sh /
COPY supervisord.conf /
RUN chmod +x /run.sh

CMD /run.sh
