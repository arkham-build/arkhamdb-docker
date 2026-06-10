FROM php:7.4-apache AS base

# enable mod_rewrite.
RUN a2enmod rewrite

# import custom PHP config.
COPY build/docker-php-custom.ini /usr/local/etc/php/conf.d/

# arkhamdb does not install correctly with composer v2, use v1.
COPY --from=composer:1.10.26 /usr/bin/composer /usr/local/bin/composer

# install composer dependencies.
RUN apt update && apt install -y git unzip wget

# install required PHP extensions.
RUN docker-php-ext-install \
  mysqli \
  pdo \
  pdo_mysql

# change document root for apache.
ENV APACHE_DOCUMENT_ROOT /code/web
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

FROM base AS builder

WORKDIR /build

# suppress composer install warning.
ENV COMPOSER_ALLOW_SUPERUSER 1

# make envs used in `parameters.yml` available to `composer install`.
ARG MYSQL_DATABASE
ARG MYSQL_DOCKER_HOST_NAME
ARG MYSQL_PASSWORD
ARG MYSQL_TCP_PORT
ARG MYSQL_USER
ENV MYSQL_DATABASE $MYSQL_DATABASE
ENV MYSQL_DATABASE $MYSQL_DOCKER_HOST_NAME
ENV MYSQL_DATABASE $MYSQL_DATABASE
ENV MYSQL_DATABASE $MYSQL_TCP_PORT
ENV MYSQL_USER $MYSQL_USER

# copy app to container.
COPY arkhamdb .

# apply local development patches.
COPY build/patches/disable-local-signup-captcha.patch /tmp/disable-local-signup-captcha.patch
RUN rm -rf .git && git apply -p1 /tmp/disable-local-signup-captcha.patch

# copy pre-configured parameters to container.
# needs to be present before composer install is run.
COPY build/parameters.yml ./app/config/parameters.yml

RUN composer install --no-interaction

FROM base AS final

WORKDIR /code

COPY --from=builder /build/ .

# allow httpd user access to write cache and logs.
RUN chown www-data:www-data -R ./var/cache/ ./var/logs/

# redirect to production app - app_dev does not run behind reverse proxy.
RUN sed -ri -e 's!app_dev.php!app.php!g' ./web/.htaccess
