# docker/itop/Dockerfile

FROM webdevops/php-apache:8.1

# Install OS dependencies
RUN apt-get update && apt-get install -y \
    mariadb-client \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libldap2-dev \
    libonig-dev \
    libc-client-dev \
    libkrb5-dev \
    unzip \
    graphviz \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY docker/itop/custom-php.ini /opt/docker/etc/php/php.ini

# Required for IMAP build
RUN ln -s /usr/lib/x86_64-linux-gnu/libc-client.a /usr/lib/libc-client.a || true

# Configure and install GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Configure IMAP with Kerberos
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    gd \
    zip \
    curl \
    soap \
    mbstring \
    xml \
    ldap \
    imap

# Install APCu via PECL
# RUN pecl install apcu && docker-php-ext-enable apcu
RUN docker-php-ext-enable apcu || true
