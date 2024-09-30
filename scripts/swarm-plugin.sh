#!/bin/bash
set -e

# Wait for Nextcloud to be ready
until gosu www-data php occ status; do
    echo "Waiting for Nextcloud to be ready..."
    sleep 10
done

# Enable and install the apps once Nextcloud is ready
gosu www-data php occ app:enable files_external
gosu www-data php occ app:install files_external_ethswarm
gosu www-data php occ app:enable files_external_ethswarm

echo "Starting supervisord..."
exec /usr/bin/supervisord -c /supervisord.conf