# !/bin/sh

# wait for RabbitMQ server to start
sleep 5

# Replace * with name of Django Project
cd project
su -m myuser -c "celery -A myshop worker -l INFO"