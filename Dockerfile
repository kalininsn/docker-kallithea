FROM ubuntu:14.04

MAINTAINER kalininsn@gmail.com

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python python-pip python-ldap mercurial git \
                       python-dev software-properties-common libmysqlclient-dev libpq-dev && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-get update && \
    apt-get install -y nginx && \
    \
    mkdir /kallithea && \
    cd /kallithea && \
    mkdir -m 0777 config repos logs && \
    hg clone https://kallithea-scm.org/repos/kallithea -u stable && \
    cd kallithea && \
    rm -r .hg && \
    pip install --upgrade pip setuptools && \
    pip install -e . && \
    python setup.py compile_catalog && \
    \
    pip install mysql-python && \
    pip install psycopg2 && \
    \
    apt-get purge --auto-remove -y python-dev software-properties-common && \
    \
    rm /etc/nginx/sites-enabled/*
RUN locale-gen ru_RU.UTF-8 && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=ru_RU.UTF-8 LC_MESSAGES=POSIX && \
    export LC_ALL=ru_RU.UTF-8

ADD kallithea_vhost /etc/nginx/sites-enabled/kallithea_vhost
ADD run.sh /kallithea/run.sh

VOLUME ["/kallithea/config", "/kallithea/repos", "/kallithea/logs"]

EXPOSE 80

CMD ["/kallithea/run.sh"]
