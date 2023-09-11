#!/bin/sh

# wait for PSQL server to start
sleep 10

su -m myuser -c "python project/manage.py makemigrations"
su -m myuser -c "python project/manage.py migrate"
# su -m myuser -c "python project/manage.py collectstatic --no-input"
su -m root -c "python project/manage.py runserver 0.0.0.0:8000"