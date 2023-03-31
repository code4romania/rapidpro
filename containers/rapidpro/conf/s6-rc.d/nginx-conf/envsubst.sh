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
fi

envsubst '
$MAILROOM_HOST
$MAILROOM_PORT
$COURIER_HOST
$COURIER_PORT
$WORKER_PROCESSES
$WORKER_CONNECTIONS
$RESOLVER
' </etc/nginx/templates/nginx.conf >/etc/nginx/nginx.conf
