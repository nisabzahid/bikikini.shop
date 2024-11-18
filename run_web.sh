#!/bin/sh

# Wait for database to be ready
while ! nc -z db 5432; do
  echo "Waiting for database..."
  sleep 1
done

# Run as non-root user
APP_USER=myuser

# Apply database migrations
su -m $APP_USER -c "python project/manage.py makemigrations"
su -m $APP_USER -c "python project/manage.py migrate"

# Load initial data if needed
if [ "$DJANGO_ENV" = "development" ]; then
    su -m $APP_USER -c "python project/manage.py loaddata data.json"
fi

# Start server based on environment
if [ "$DJANGO_ENV" = "production" ]; then
    su -m $APP_USER -c "gunicorn --workers=4 --bind=0.0.0.0:8000 project.wsgi:application"
else
    su -m $APP_USER -c "python project/manage.py runserver 0.0.0.0:8000"
fi
# wait for PSQL server to start
sleep 10

su -m myuser -c "flake8 && black . && isort -y"
su -m myuser -c "python project/manage.py makemigrations"
su -m myuser -c "python project/manage.py migrate"
su -m root -c "python project/manage.py collectstatic --no-input"
su -m root -c "python project/manage.py loaddata data.json"
su -m root -c "python project/manage.py runserver 0.0.0.0:8000"