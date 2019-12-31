FROM php:7.3-apache

ENV PERSISTENT_DEPS libmongoc-1.0-0 libpq5 libldap-common zlib1g libicu63 zip librabbitmq

RUN apt-get update && apt-get install -y --no-install-recommends \
    $PERSISTENT_DEPS \
    git && \
    rm -rf /var/lib/apt/lists/*

ENV BUILD_DEPS libmongoc-dev libc-client-dev libpq-dev libldap-dev zlib1g-dev libicu-dev libkrb5-dev libgcrypt20-dev libmagickwand-dev libzip-dev librabbitmq-dev

ENV APCU_VERSION 5.1.18
ENV XDEBUG_VERSION 2.9.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    $BUILD_DEPS && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl  && \
    docker-php-ext-install intl pdo_mysql pdo_pgsql zip bcmath ldap imap sockets gd && \
    pecl install apcu-${APCU_VERSION} redis imagick xdebug-${XDEBUG_VERSION} amqp && \
    docker-php-ext-enable --ini-name 20-apcu.ini apcu && \
    docker-php-ext-enable --ini-name 05-opcache.ini opcache && \
    docker-php-ext-enable redis && \
    docker-php-ext-enable --ini-name 06-imagick.ini imagick && \
    docker-php-ext-enable --ini-name 07-imap.ini imap && \
    docker-php-ext-enable ldap sockets gd && \
    pecl download mongodb-1.5.2 && tar xvzf mongodb-1.5.2.tgz -C /tmp && rm -rf mongodb-1.5.2.tgz && curl -fsSL 'https://patch-diff.githubusercontent.com/raw/mongodb/mongo-c-driver/pull/526.patch' -o /tmp/526.patch && \
    cd /tmp/mongodb-1.5.2 && git apply --directory=src/libmongoc /tmp/526.patch && cd - && docker-php-ext-configure /tmp/mongodb-1.5.2 && docker-php-ext-install /tmp/mongodb-1.5.2 && rm -rf /tmp/mongodb-1.5.2 /tmp/526.patch && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /srv/project