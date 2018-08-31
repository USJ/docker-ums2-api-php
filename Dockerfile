FROM php:7.2-fpm-alpine

RUN apk add --no-cache --virtual .persistent-deps \
    git \
    icu-libs \
    zlib \
    imagemagick \
    c-client \
    libsasl \
    libldap \
    libpq \
    grep

ENV APCU_VERSION 5.1.8

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    icu-dev \
    zlib-dev \
    imap-dev \
    pkgconf \
    imagemagick-dev \
    libtool \
    openldap-dev \
    postgresql-dev \
    && docker-php-ext-install \
    intl \
    pdo_mysql \
    pdo_pgsql \
    zip \
    bcmath \
    imap \
    ldap \
    && pecl install \
    apcu-${APCU_VERSION} \
    redis \
    imagick \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable --ini-name 06-imagick.ini imagick \
    && docker-php-ext-enable --ini-name 07-imap.ini imap \
    && docker-php-ext-enable ldap \
    && pecl download mongodb-1.5.2 && tar xvzf mongodb-1.5.2.tgz -C /tmp && rm -rf mongodb-1.5.2.tgz && curl -fsSL 'https://patch-diff.githubusercontent.com/raw/mongodb/mongo-c-driver/pull/526.patch' -o /tmp/526.patch \
    && cd /tmp/mongodb-1.5.2 && git apply --directory=src/libmongoc /tmp/526.patch && cd - && docker-php-ext-configure /tmp/mongodb-1.5.2 && docker-php-ext-install /tmp/mongodb-1.5.2 && rm -rf /tmp/mongodb-1.5.2 && rm -rf /tmp/526.patch \
    && apk del .build-deps

COPY docker-entrypoint.sh /usr/local/bin/docker-app-entrypoint
RUN chmod +x /usr/local/bin/docker-app-entrypoint

COPY php.ini /usr/local/etc/php/php.ini

ENTRYPOINT ["docker-app-entrypoint"]
CMD ["php-fpm"]
