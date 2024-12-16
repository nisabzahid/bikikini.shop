#!/bin/bash
set -e

# Ensure proper ownership of the project directory
project_dir="."  # Replace with actual project path
chown -R "$APP_USER:$APP_USER" "$project_dir"

# # Run code quality checks
# flake8
# black .
# isort -y

# Apply database migrations
python project/manage.py makemigrations
python project/manage.py migrate

# Collect static files
python project/manage.py collectstatic --no-input

# # Load initial data if needed
# if [ "$DJANGO_ENV" = "development" ]; then
#     if [ -f project/data.json ]; then
#         # Create fixtures directory if it doesn't exist
#         mkdir -p project/myshop/fixtures
#         # Copy data.json to fixtures directory
#         cp project/data.json project/myshop/fixtures/
#         python project/manage.py loaddata data
#     else
#         echo "No data.json fixture found, skipping fixture loading"
#     fi
# fi

# Create health check endpoint if it doesn't exist
if [ ! -f project/myshop/health/views.py ]; then
    mkdir -p project/myshop/health
    cat > project/myshop/health/views.py << EOL
from django.http import HttpResponse

def health_check(request):
    return HttpResponse("OK")
EOL
    # Create __init__.py to make it a proper Python package
    touch project/myshop/health/__init__.py
    
    # Ensure proper permissions
    chown -R "$APP_USER:$APP_USER" project/myshop/health/
fi

# Start Gunicorn
if [ "$DJANGO_ENV" = "production" ]; then
    # Production settings
    gunicorn --workers=4 \
             --bind=0.0.0.0:8000 \
             --access-logfile=- \
             --error-logfile=- \
             --log-level=info \
             --worker-class=gthread \
             --threads=4 \
             --timeout=30 \
             project.myshop.wsgi:application
else
    # Development settings
    gunicorn --workers=2 \
             --bind=0.0.0.0:8000 \
             --access-logfile=- \
             --error-logfile=- \
             --log-level=debug \
             --reload \
             project.myshop.wsgi:application
fi