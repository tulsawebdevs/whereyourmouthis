#!/bin/bash
cd wymi
gunicorn_django -b 0.0.0.0:$PORT -w 3
