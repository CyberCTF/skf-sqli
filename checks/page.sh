#!/bin/sh
# A page is read from the database by its id in the URL.
set -e
H=http://web:5000
curl -fsS "$H/home/1" | grep -q "The welcome page"
