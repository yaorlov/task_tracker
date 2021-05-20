# README

## How to run the application

1. Run `docker-compose up` to run Postgres
2. Run `bundle exec rails s` to run the app

## Database setup

Run `bundle exec rails db:create db:migrate` to create the database and the database tables
Run `bundle exec rails db:seed` to create users with tasks
