FROM golang:1.17.8-bullseye@sha256:0e3fb14a9d467437382bc5adc945838a0959b3c03990d15b4d2aa425846bf671 as supercronic

# renovate: datasource=github-tags depName=aptible/supercronic versioning=semver
ENV SUPERCRONIC_VERSION v0.1.12

RUN set -ex; \
    git clone --branch $SUPERCRONIC_VERSION https://github.com/aptible/supercronic; \
    cd supercronic; \
    go mod vendor; \
    go install;

FROM nextcloud:23.0.2-fpm@sha256:1cc413c1d54594eb2b22e8278cdb1612b17044c073e5d2a2da5f4d0355b8d67c

COPY --from=supercronic /go/bin/supercronic /usr/local/bin/supercronic

ENV PHP_MEMORY_LIMIT 1024M
ENV PHP_UPLOAD_LIMIT 16G
ENV PHP_EXECUTION_TIME 3600

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        supervisor \
        ffmpeg \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    chmod +x /usr/local/bin/supercronic; \
    echo '*/5 * * * * php -f /var/www/html/cron.php' > /crontab; \
    \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
    \
    { \
        echo "memory_limit=${PHP_MEMORY_LIMIT}"; \
        echo "upload_max_filesize=${PHP_UPLOAD_LIMIT}"; \
        echo "post_max_size=${PHP_UPLOAD_LIMIT}"; \
        echo "max_execution_time=${PHP_EXECUTION_TIME}"; \
        echo "max_input_time=${PHP_EXECUTION_TIME}"; \
    } > /usr/local/etc/php/conf.d/nextcloud.ini;

COPY supervisord.conf /

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
