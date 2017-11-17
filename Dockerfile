# ================================================================================================================
#
# PHP-FPM
#
# My personal derivation from official php fpm-alpine alpine image including
# - default configuration
# - main common extension for most of PHP projects
#

#
# ================================================================================================================

# Base is official php image
FROM php:7.1.11-fpm-alpine

# Maintainer
MAINTAINER alban.montaigu@gmail.com


# Install prerequisities
RUN apk add --no-cache pcre-dev && \

# First install php gd extension
# @see https://github.com/docker-library/php/issues/225
    apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
    docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ && \
    NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
    docker-php-ext-install -j${NPROC} gd && \

# Install imagick
# @see https://github.com/m2sh/php7/blob/master/alpine/Dockerfile
    apk add --no-cache imagemagick imagemagick-dev && \
    apk add --no-cache --virtual .imagick-build-dependencies libtool make autoconf gcc g++ && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    apk del --no-cache .imagick-build-dependencies && \

# Install mcrypt
    apk --no-cache add libmcrypt libmcrypt-dev && \
    docker-php-ext-install mcrypt && \

# Install zip
# @see https://github.com/m2sh/php7/blob/master/alpine/Dockerfile
    apk add --update --no-cache zlib zlib-dev && \
    docker-php-ext-install zip && \

# Install intl
# @see https://github.com/docker-library/php/issues/326
    apk add --update --no-cache icu-dev intl intl-dev && \
    docker-php-ext-install intl && \

# Install gettext
# @see https://github.com/docker-library/php/issues/326
    apk add --update --no-cache gettext gettext-dev && \
    docker-php-ext-install gettext && \

# Install other common extensions
    docker-php-ext-install mbstring mysqli pdo_mysql exif opcache && \

# Install composer since more php apps require it
    curl -s http://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# Custom php configuration files
COPY ./conf/php/php.ini $PHP_INI_DIR/
COPY ./conf/php/php-cli.ini $PHP_INI_DIR/
COPY ./conf/php-fpm.d/*.conf /usr/local/etc/php-fpm.d/
COPY ./conf/php-fpm.conf /usr/local/etc/

# Volumes to share
VOLUME ["/var/www"]
WORKDIR /var/www
