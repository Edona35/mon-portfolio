
FROM php:8.4-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libicu-dev \
    && docker-php-ext-install intl \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

ENV APP_ENV=prod
ENV APP_DEBUG=0

COPY . .

RUN touch .env \
    && composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader --no-scripts \
    && php bin/console importmap:install --env=prod \
    && php bin/console asset-map:compile --env=prod \
    && mkdir -p var/cache var/log \
    && chown -R www-data:www-data var

RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && printf '\n<Directory /var/www/html/public>\nAllowOverride All\nRequire all granted\nFallbackResource /index.php\n</Directory>\n' >> /etc/apache2/apache2.conf

EXPOSE 80