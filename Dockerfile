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

# First install php gd extension
# @see https://github.com/docker-library/php/issues/225
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
    docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ && \
    NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
    docker-php-ext-install -j${NPROC} gd && \
    apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev && \

# Install imagick
# @see https://github.com/m2sh/php7/blob/master/alpine/Dockerfile
    apk add --update --no-cache autoconf g++ imagemagick-dev libtool make pcre-dev && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    apk del --no-cache autoconf g++ libtool make pcre-dev && \

# Install mcrypt
  apk --no-cache add libmcrypt-dev && \
  docker-php-ext-install mcrypt && \

# Install composer since more php apps require it
    curl -s http://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer