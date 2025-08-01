FROM golang:1.23.11-bullseye@sha256:c305323f786e970282365b4c96db0ce551b3b9a67ecebf4162c9bb7a7c64418b as supercronic

# renovate: datasource=github-tags depName=aptible/supercronic versioning=semver
ENV SUPERCRONIC_VERSION v0.2.33

RUN set -ex; \
    git clone --branch $SUPERCRONIC_VERSION https://github.com/aptible/supercronic; \
    cd supercronic; \
    go mod vendor; \
    go install;


FROM nextcloud:30.0.13-fpm@sha256:df8a10a65123d07805d599d370ffbfa6b4a370600a8187cbf76bcf4a6678bbe3

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
        gosu \
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

ENV NEXTCLOUD_UPDATE=1

COPY supervisord.conf /

# Define the command to run at container start using an inline shell script
ENTRYPOINT ["/bin/bash", "-c", " \
    set -e; \   
    echo 'Starting supervisord...'; \
    exec /usr/bin/supervisord -c /supervisord.conf; \
    echo 'Waiting for Nextcloud to be ready...'; \
    until gosu www-data php occ status >/dev/null 2>&1; do \
        echo 'Nextcloud is not ready yet, retrying in 10 seconds...'; \
        sleep 10; \
    done; \
    echo 'Nextcloud is ready.'; \
    if ! gosu www-data php occ app:list | grep -q 'files_external: enabled'; then \
        echo 'Enabling files_external app...'; \
        gosu www-data php occ app:enable files_external; \
    else \
        echo 'files_external app is already enabled.'; \
    fi; \
    if ! gosu www-data php occ app:list | grep -q 'files_external_ethswarm'; then \
        echo 'Installing and enabling files_external_ethswarm app...'; \
        gosu www-data php occ app:install files_external_ethswarm; \
        gosu www-data php occ app:enable files_external_ethswarm; \
    else \
        echo 'files_external_ethswarm app is already installed and enabled.'; \
    fi; \
    echo 'All apps are enabled and installed successfully.'; \
"]