FROM arm32v7/ubuntu:18.04
MAINTAINER Przemek Grondek <pgrondek@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y stubby && \
    apt-get clean

COPY stubby.yml /etc/stubby/stubby.yml

EXPOSE 53
CMD /usr/bin/stubby
