FROM php:8.3-cli

WORKDIR /app

# Install PHP extensions required by composer.json and runtime.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libxml2-dev \
        libzip-dev \
        libonig-dev \
    && docker-php-ext-install -j"$(nproc)" dom mbstring soap \
    && rm -rf /var/lib/apt/lists/*

# Install Composer.
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install dependencies first to leverage Docker layer caching.
COPY composer.json ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Copy application source.
COPY . .

# Render injects PORT; default to 10000 for local runs.
ENV PORT=10000
EXPOSE 10000

CMD ["sh", "-c", "php -S 0.0.0.0:${PORT} -t public"]
