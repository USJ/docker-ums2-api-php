FROM php:7.2-apache

ENV PERSISTENT_DEPS libmongoc-1.0-0 libpq5 libldap-common zlib1g libicu57

RUN apt-get update && apt-get install -y --no-install-recommends \
    $PERSISTENT_DEPS \
    git && \
    rm -rf /var/lib/apt/lists/*

ENV BUILD_DEPS libmongoc-dev libc-client-dev libpq-dev libldap-dev zlib1g-dev libicu-dev libkrb5-dev libgcrypt11-dev libmagickwand-dev libcurl4-openssl-dev pkg-config libssl-dev librabbitmq-dev

ENV APCU_VERSION 5.1.8
ENV MONGODB_DRIVER_VERSION 1.5.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    $BUILD_DEPS && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl  && \
    docker-php-ext-install intl pdo_mysql pdo_pgsql zip bcmath ldap imap sockets && \
    pecl install apcu-${APCU_VERSION} redis imagick mongodb-${MONGODB_DRIVER_VERSION} amqp && \
    docker-php-ext-enable --ini-name 20-apcu.ini apcu && \
    docker-php-ext-enable --ini-name 05-opcache.ini opcache && \
    docker-php-ext-enable --ini-name 06-imagick.ini imagick && \
    docker-php-ext-enable --ini-name 07-imap.ini imap && \
    docker-php-ext-enable redis mongodb amqp ldap && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /srv/project