FROM ubuntu:16.04
MAINTAINER Przemek Grondek <github@nerull7.info>

ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y backuppc gosu supervisor && \
    apt-get clean && \
    htpasswd -bB /etc/backuppc/htpasswd backuppc backuppc && \
    mkdir -p /var/run/backuppc && \
    chown backuppc:backuppc /var/run/backuppc && \
    sed -i "s/Alias \/backuppc/Alias \//g" /etc/backuppc/apache.conf

COPY supervisord.conf /

EXPOSE 80
VOLUME ["/etc/backuppc", \
        "/var/lib/backuppc"]

CMD ["supervisord", "-n", "-c", "/supervisord.conf"]