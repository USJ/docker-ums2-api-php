FROM php:7.1-fpm-alpine

RUN apk add --no-cache --virtual .persistent-deps \
    git \
    icu-libs \
    zlib \
    imagemagick \
    c-client \
    libsasl \
    libldap \
    grep

ENV APCU_VERSION 5.1.8

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    icu-dev \
    zlib-dev \
    imap-dev \
    pkgconf \
    openssl-dev \
    imagemagick-dev \
    libtool \
    openldap-dev \
    && docker-php-ext-install \
    intl \
    pdo_mysql \
    zip \
    bcmath \
    imap \
    ldap \
    && pecl install \
    apcu-${APCU_VERSION} \
    mongodb \
    redis \
    imagick \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-enable --ini-name 06-imagick.ini imagick \
    && docker-php-ext-enable --ini-name 07-imap.ini imap \
    && docker-php-ext-enable ldap \
    && apk del .build-deps

COPY docker-entrypoint.sh /usr/local/bin/docker-app-entrypoint
RUN chmod +x /usr/local/bin/docker-app-entrypoint

COPY php.ini /usr/local/etc/php/php.ini

ENTRYPOINT ["docker-app-entrypoint"]
CMD ["php-fpm"]
