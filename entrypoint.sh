#!/bin/bash

if [[ "$@" = *bash* ]]; then
  exec "$@"
  exit 0
fi

if [[ -n "$DISABLED_PHP_EXTS" ]]; then
  for e in `echo $DISABLED_PHP_EXTS | tr ',' ' '`; do
    extPath=/usr/local/etc/php/conf.d/docker-php-ext-$e.ini
    if [[ -f $extPath ]]; then
      mv $extPath $extPath.disabled
    elif [[ ! -f $extPath.disabled ]]; then
      echo Unsupported extension: $e
    fi
  done
fi

if [[ -n "$ENABLED_PHP_EXTS" ]]; then
  for e in `echo $ENABLED_PHP_EXTS | tr ',' ' '`; do
    extPath=/usr/local/etc/php/conf.d/docker-php-ext-$e.ini
    if [[ -f $extPath.disabled ]]; then
      mv $extPath.disabled $extPath
    elif [[ ! -f $extPath ]]; then
      echo Unsupported extension: $e
    fi
  done
fi

exec "$@"
