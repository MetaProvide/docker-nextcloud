FROM golang:1.18.6-bullseye@sha256:251acc9398339576ae2a8706c294263440fc400fef0e742b5747789cfd7078cb as supercronic

# renovate: datasource=github-tags depName=aptible/supercronic versioning=semver
ENV SUPERCRONIC_VERSION v0.1.13

RUN set -ex; \
    git clone --branch $SUPERCRONIC_VERSION https://github.com/aptible/supercronic; \
    cd supercronic; \
    go mod vendor; \
    go install;

FROM nextcloud:24.0.5-fpm@sha256:5f880601e2492b4c07cb25faaf78f21aad50cdfb049a3f0049b1a30be0cf49b7

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
