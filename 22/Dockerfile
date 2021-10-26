FROM golang:1.17.2-bullseye@sha256:f9292045d12e5935e9364949adc4ea00f700eb2f775058dc0bb6cc2dd04ab315 as supercronic

# renovate: datasource=github-tags depName=aptible/supercronic versioning=semver
ENV SUPERCRONIC_VERSION v0.1.12

RUN set -ex; \
    git clone --branch $SUPERCRONIC_VERSION https://github.com/aptible/supercronic; \
    cd supercronic; \
    go mod vendor; \
    go install;

FROM nextcloud:22.2.0-fpm@sha256:10e4e705a85874b847026a06a3b05126fadf36808ff197ee71bef7d19676513f

COPY --from=supercronic /go/bin/supercronic /usr/local/bin/supercronic

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
    echo 'memory_limit=1024M' > /usr/local/etc/php/conf.d/memory-limit.ini;

COPY supervisord.conf /
COPY nextcloud.ini /usr/local/etc/php/conf.d/

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
