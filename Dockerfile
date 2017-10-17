FROM php:7.0-alpine

MAINTAINER Spencer Rinehart <anubis@overthemonkey.com>

ENV COMPOSER_HOME /.composer
ENV PATH $COMPOSER_HOME/vendor/bin:$PATH

RUN addgroup alpine && adduser -G alpine -s /bin/sh -D alpine && \
    apk add --update --virtual composer-deps autoconf alpine-sdk && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    docker-php-ext-install mbstring && \
    apk del composer-deps && \
    rm -rf /apk /tmp/* /var/cache/apk/* && \
    mkdir -p /home/alpine/.composer/vendor/bin && \
    chown -R alpine:alpine /home/alpine/.composer && \
    mkdir /code && \
    chown alpine:alpine /code && \
    mkdir -p $COMPOSER_HOME/vendor/bin && \
    curl -sSL https://getcomposer.org/installer | \ 
    php -- --install-dir=$COMPOSER_HOME/vendor/bin --filename=composer

ENV COMPOSER_HOME /home/alpine/.composer
ENV PATH $COMPOSER_HOME/vendor/bin:$PATH

USER alpine
WORKDIR /code

ENTRYPOINT ["composer"]
CMD ["--help"]
