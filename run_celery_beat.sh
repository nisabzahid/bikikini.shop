!/bin/sh

wait for RabbitMQ server to start
sleep 5

# APP_USER=myuser

# # Create user if it doesn't exist
# if ! id "$APP_USER" >/dev/null 2>&1; then
#     useradd -m -s /bin/bash "$APP_USER"
# fi


# # Function to run commands as APP_USER
# run_as_user() {
#     su -m "$APP_USER" -c "$1"
# }

rm /tmp/celerybeat-doshi.pid > /dev/null

# Replace * with name of Django Project
cd project
celery -A myshop beat -s /home/celery/var/run/celerybeat-schedule