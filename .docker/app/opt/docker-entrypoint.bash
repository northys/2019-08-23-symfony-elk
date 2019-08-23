#!/usr/bin/dumb-init /bin/sh
php-fpm -D
nginx -g "daemon off;"
