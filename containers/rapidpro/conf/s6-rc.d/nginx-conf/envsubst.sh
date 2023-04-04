#!/command/with-contenv sh

export WORKER_PROCESSES=$(nproc)
export WORKER_CONNECTIONS=$(expr $(ulimit -n) / $WORKER_PROCESSES)

# nginx only resolves hostnames on startup. You can use variables
# with proxy_pass to get it to use the resolver for runtime lookups.
#
# @see: https://stackoverflow.com/a/56402035
if [ -n "${AWS_EXECUTION_ENV}" ]; then
    export RESOLVER="resolver 169.254.169.253 valid=10s;"
    echo "Running in AWS ECS. Setting $RESOLVER"

    export MAILROOM_PROXY_PASS="
        $RESOLVER
        set \$mailroom http://${MAILROOM_HOST}:${MAILROOM_PORT};
        proxy_pass \$mailroom;
    "

    export COURIER_PROXY_PASS="
        $RESOLVER
        set \$courier http://${COURIER_HOST}:${COURIER_PORT};
        proxy_pass \$courier;
    "
else
    export MAILROOM_PROXY_PASS="
        proxy_pass http://${MAILROOM_HOST}:${MAILROOM_PORT};
    "

    export COURIER_PROXY_PASS="
        proxy_pass http://${COURIER_HOST}:${COURIER_PORT};
    "
fi

envsubst '
$COURIER_PROXY_PASS
$MAILROOM_PROXY_PASS
$WORKER_CONNECTIONS
$WORKER_PROCESSES
' </etc/nginx/templates/nginx.conf >/etc/nginx/nginx.conf
