#!/bin/sh
set -e

host="web"
port="8000"
timeout=30
interval=1

echo "Waiting for web service to be ready..."
elapsed=0

while ! nc -z $host $port; do
    if [ "$elapsed" -gt "$timeout" ]; then
        echo "Timeout reached waiting for web service"
        exit 1
    fi
    echo "Waiting for web service... ($elapsed/$timeout seconds)"
    sleep $interval
    elapsed=$((elapsed + interval))
done

echo "Web service is ready!"
exec "$@"