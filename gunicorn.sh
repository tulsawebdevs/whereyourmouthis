#!/bin/bash
cd wymi
./manage.py collectstatic --noinput
gunicorn_django -b 0.0.0.0:$PORT -w 3
