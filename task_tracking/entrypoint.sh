#!/bin/bash
set -e

bundle exec rails db:create
bundle exec rails db:migrate

rm -f tmp/pids/karafka

exec "$@"
