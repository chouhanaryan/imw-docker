#!/bin/sh

cd $APP_HOME

python manage.py makemigrations
python manage.py makemigrations app1
python manage.py migrate

gunicorn inventory_management.wsgi:application --bind 0.0.0.0:8000 --workers 2

exec "$@"