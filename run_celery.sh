#!/bin/sh

# wait for RabbitMQ server to start
sleep 5

# Replace * with name of Django Project
cd project
celery -A myshop worker -l DEBUG --without-heartbeat