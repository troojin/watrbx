FROM php:8.3-cli

WORKDIR /app

# Install PHP extensions required by composer.json and runtime.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        unzip \
        libxml2-dev \
        libonig-dev \
    && docker-php-ext-install -j"$(nproc)" dom mbstring soap \
    && rm -rf /var/lib/apt/lists/*

# Install Composer.
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy application source (including src/ for autoload generation) before install.
COPY . .

ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader

# Render injects PORT; default to 10000 for local runs.
ENV PORT=10000
EXPOSE 10000

CMD ["sh", "-c", "php -S 0.0.0.0:${PORT} -t public"]
