FROM golang:1.23.4-bullseye@sha256:6d4cbf0b3900afa3e4460ca995b6c351370ce8d2d44b7a964dc521ab640e1a88 as supercronic

# renovate: datasource=github-tags depName=aptible/supercronic versioning=semver
ENV SUPERCRONIC_VERSION v0.2.33

RUN set -ex; \
    git clone --branch $SUPERCRONIC_VERSION https://github.com/aptible/supercronic; \
    cd supercronic; \
    go mod vendor; \
    go install;


FROM nextcloud:28.0.14-fpm@sha256:b299421f866096655f2a9112d6a1b8767d682c0801c566887dad44edaab445bc


COPY --from=supercronic /go/bin/supercronic /usr/local/bin/supercronic

ENV PHP_MEMORY_LIMIT 4048M
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
