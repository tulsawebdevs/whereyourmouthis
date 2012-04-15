#!/bin/bash
cd wymi
./manage.py collectstatic
gunicorn_django -b 0.0.0.0:$PORT -w 3
