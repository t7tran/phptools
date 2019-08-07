FROM php:7.2-alpine

MAINTAINER Spencer Rinehart <anubis@overthemonkey.com>

COPY entrypoint.sh /

ENV COMPOSER_HOME /.composer
ENV PATH /code/bin:$COMPOSER_HOME/vendor/bin:$PATH

RUN addgroup alpine && adduser -G alpine -s /bin/sh -D alpine && \
    apk add --update --virtual mod-deps autoconf alpine-sdk \
            libmcrypt-dev && \
    # install other tools
    apk add bash git jq xmlstarlet \
            zip unzip \
            apache2-utils \
            coreutils \
            libltdl && \
    # imap dependencies
    apk add imap-dev krb5-dev openssl-dev && \
    # gd dependencies
    apk add freetype-dev \
            libjpeg-turbo-dev \
            libpng-dev \
    # gmp dependencies
            gmp-dev && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-configure gmp && \
    docker-php-ext-install -j$(nproc) \
            mbstring \
            gd \
            zip \
            opcache \
            imap \
            pdo_mysql \
            mysqli \
            gmp && \
    # install runkit
    wget https://github.com/runkit7/runkit7/releases/download/2.0.3/runkit7-2.0.3.tgz -O /tmp/runkit.tgz && \
    pecl install /tmp/runkit.tgz && \
    echo -e 'extension=runkit.so\nrunkit.internal_override=On' > /usr/local/etc/php/conf.d/docker-php-ext-runkit.ini && \
    # install uopz
    pecl install uopz && \
    docker-php-ext-enable uopz && \
    # allow exit/die by default
    echo uopz.exit=1 >> /usr/local/etc/php/conf.d/docker-php-ext-uopz.ini && \
    # install pcov
    pecl install pcov && \
    docker-php-ext-enable pcov && \
    # disable pcov by default
    mv /usr/local/etc/php/conf.d/docker-php-ext-pcov.ini /usr/local/etc/php/conf.d/docker-php-ext-pcov.ini.disabled && \
    # install xdebug
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    # disable xdebug as it interferes with uopz
    mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.disabled && \
    # setup
    chmod +x /entrypoint.sh && \
    chown -R alpine:alpine /usr/local/etc/php/conf.d && \
    # configure working folder
    mkdir /code && \
    chown alpine:alpine /code && \
    # install composer
    mkdir -p $COMPOSER_HOME/cache && \
    chmod 777 $COMPOSER_HOME/cache && \
    mkdir -p $COMPOSER_HOME/vendor/bin && \
    curl -sSL https://getcomposer.org/installer | \ 
    php -- --install-dir=$COMPOSER_HOME/vendor/bin --filename=composer && \
    # clean up
    apk del mod-deps && \
    rm -rf /apk /tmp/* /var/cache/apk/*

USER alpine
WORKDIR /code

VOLUME /.composer/cache

ENTRYPOINT ["/entrypoint.sh"]
CMD ["echo", "Please specify a command to run, e.g. composer install"]
