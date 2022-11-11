#!/bin/bash
set -e

bundle exec rails db:create
bundle exec rails db:migrate

whenever --update-crontab --set environment='development'

rm -f tmp/pids/karafka 

exec "$@"
