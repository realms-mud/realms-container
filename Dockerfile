# syntax=docker/dockerfile:1

FROM ubuntu:latest

ENV USER root

RUN echo realms > /etc/hostname

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get install -y software-properties-common

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gcc \
    libtool-bin \
    make \
    apt-utils \
    curl \
    git-core \
    mysql-server \
    python-is-python3 \
    libgcrypt20-dev \
    libmysqlclient-dev \
    bison \
    libbison-dev \
    telnet \
    vim

ENV TZ=America/New_York
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install tzdata

RUN echo '[mysqld]\nlog_bin_trust_function_creators = 1\n' \
    >> /etc/mysql/my.cnf

RUN usermod -d /var/lib/mysql mysql
RUN service mysql start

RUN mkdir /mud

RUN cd /mud

RUN git clone https://github.com/realms-mud/ldmud.git/ /mud/ldmud

RUN git clone https://github.com/realms-mud/core-lib.git /mud/lib

RUN cp -r /mud/ldmud/mudlib/sys /mud/lib/

RUN cp -r /mud/ldmud/doc /mud/lib/

ADD prep-database.pl /mud/prep-database.pl
ADD create_db.pl /mud/create_db.pl
ADD driver /mud/driver

RUN chmod 755 /mud/prep-database.pl
RUN chmod 755 /mud/create_db.pl
RUN chmod 755 /mud/driver

RUN sed -i 's/user. : NULL/user\) : "RealmsLib"/' /mud/ldmud/src/pkg-mysql.c

RUN sed -i 's/password. : NULL/password\) : "'`/mud/prep-database.pl`'"/' \
    /mud/ldmud/src/pkg-mysql.c

WORKDIR /mud/ldmud/src 

RUN ./autogen.sh
RUN ./configure --prefix=/mud \
              --with-read-file-max-size=0 \
              --with-portno=23 \
              --enable-erq=xerq \
              --with-udp-port=4246 \
              --with-catch-reserved-cost=10000 \
              --with-malloc=smalloc \
              --enable-dynamic-costs \
              --enable-opcprof \
              --enable-verbose-opcprof \
              --enable-yydebug \
              --with-time-to-clean_up=864000 \
              --with-time-to-swap=86400 \
              --with-time-to-swap-variables=86400 \
              --with-evaluator-stack-size=131072 \
              --with-max-user-trace=131072 \
              --with-max-trace=131172 \
              --with-compiler-stack-size=65536 \
              --with-max-cost=268435456 \
              --with-max-array-size=0 \
              --with-max-mapping-size=0 \
              --with-htable-size=65536 \
              --with-itable-size=32768 \
              --with-otable-size=65536 \
              --with-hard-malloc-limit=0 \
              --disable-use-pcre \
              --enable-use-mysql

RUN make -j 8

WORKDIR /mud/lib

EXPOSE 23/tcp

ENTRYPOINT service mysql start && /mud/create_db.pl && /mud/driver && /bin/bash
