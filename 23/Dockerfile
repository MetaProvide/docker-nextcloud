FROM golang:1.17.5-bullseye@sha256:2cd7d9dffb9961c032ec43cdd58be9dbf6e3079acc3f575c2a3e497a3b62b90c as supercronic

# renovate: datasource=github-tags depName=aptible/supercronic versioning=semver
ENV SUPERCRONIC_VERSION v0.1.12

RUN set -ex; \
    git clone --branch $SUPERCRONIC_VERSION https://github.com/aptible/supercronic; \
    cd supercronic; \
    go mod vendor; \
    go install;

FROM nextcloud:23.0.0-fpm@sha256:99fe2e44bca336f37447f11db6ee96d5f5805091b3e6e9268b3d025c4c269c99

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
