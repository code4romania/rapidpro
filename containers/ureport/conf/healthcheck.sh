#!/usr/bin/env sh

services="nginx ureport"

for service in $services; do
    # service is up
    if [ "$(/command/s6-svstat -u /run/service/$service)" = "true" ]; then
        continue
    fi

    # service is down
    exit "$(/command/s6-svstat -e /run/service/$service)"
done

exit 0
