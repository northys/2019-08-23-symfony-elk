FROM php:7.2-fpm-alpine

ENV APP_ENV=prod

WORKDIR /var/www/app

RUN apk --update add \
    curl \
    bash \
    build-base \
    libmemcached-dev \
    libmcrypt-dev \
    libxml2-dev \
    zlib-dev \
    autoconf \
    cyrus-sasl-dev \
    libgsasl-dev \
    # Install extensions
    && docker-php-ext-install \
        opcache \
        bcmath \
        mbstring \
        pdo \
        tokenizer \
        xml \
        pcntl \
    && apk --update add libzip-dev \
        && docker-php-ext-configure zip --with-libzip \
        && docker-php-ext-install zip \
    && pecl channel-update pecl.php.net \
        && pecl install mcrypt-1.0.1 \
    # Install composer
    && curl https://getcomposer.org/composer.phar -o /bin/composer \
        && chmod +x /bin/composer

# Instal php-redis extension
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Setup FPM
ADD .docker/app/usr/local/etc/php/conf.d/app.ini /usr/local/etc/php/conf.d/app.ini
ADD .docker/app/usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

# package app, see .dockerignore
ADD . .

# Install app composer dependencies
RUN composer install --optimize-autoloader --classmap-authoritative \
    # Warmup cache
    && bin/console cache:warmup \
    && chown -Rvc www-data:www-data var/cache/prod

# Install dumb-init and nginx
ADD .docker/app/opt/docker-entrypoint.bash /opt/

RUN apk add --update dumb-init nginx \
    && mkdir -p /run/nginx \
    && chmod +x /opt/docker-entrypoint.bash

ADD .docker/app/etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# set dumb-init as entrypoint and run both php-fpm and nginx
ENTRYPOINT ["/usr/bin/dumb-init"]

CMD ["--", "/opt/docker-entrypoint.bash"]
