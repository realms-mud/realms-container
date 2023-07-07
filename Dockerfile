# syntax=docker/dockerfile:1

FROM ubuntu:latest

ENV USER root

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
    software-properties-common \
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

RUN echo '[mysqld]\nlog_bin_trust_function_creators = 1\n' \
    >> /etc/mysql/my.cnf; \
    usermod -d /var/lib/mysql mysql; \
    service mysql start

ADD prep-database.pl /mud/prep-database.pl
ADD create_db.pl /mud/create_db.pl
ADD driver /mud/driver

RUN mkdir /mud; \
    cd /mud; \
    chmod 755 /mud/prep-database.pl /mud/create_db.pl /mud/driver

RUN git clone https://github.com/realms-mud/ldmud.git/ /mud/ldmud

RUN sed -i 's/user. : NULL/user\) : "RealmsLib"/' /mud/ldmud/src/pkg-mysql.c; \
    sed -i 's/password. : NULL/password\) : "'`/mud/prep-database.pl`'"/' \
    /mud/ldmud/src/pkg-mysql.c

WORKDIR /mud/ldmud/src 

RUN ./autogen.sh; \
    ./configure --prefix=/mud \
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
              --enable-use-mysql; \
    make -j 8; \
    strip ldmud; \
    rm -rf *.o ../.git*

RUN git clone https://github.com/realms-mud/core-lib.git /mud/lib; \
    cp -r /mud/ldmud/mudlib/sys /mud/lib/; \
    cp -r /mud/ldmud/doc /mud/lib/; \
    mkdir /mud/lib/players; \
    apt-get clean; \
    rm -rf /mud/lib/.git* /mud/lib/demo-videos /var/lib/apt/lists/*

WORKDIR /mud/lib

EXPOSE 23/tcp

ENTRYPOINT service mysql start && /mud/create_db.pl && /mud/driver && /bin/bash
