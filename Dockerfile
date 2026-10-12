
FROM php:8.4-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libicu-dev libpq-dev \
    && docker-php-ext-install intl pdo_pgsql \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

ENV APP_ENV=prod
ENV APP_DEBUG=0
ENV APP_SECRET=replace-this-with-a-secret
ENV DATABASE_URL="postgresql://app:change_me@127.0.0.1:5432/app?serverVersion=16&charset=utf8"

COPY . .

RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && printf '\n<Directory /var/www/html/public>\nAllowOverride All\nRequire all granted\nFallbackResource /index.php\n</Directory>\n' >> /etc/apache2/apache2.conf \
    && chown -R www-data:www-data var

EXPOSE 80