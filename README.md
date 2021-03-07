# README

[Event Storming](https://docs.google.com/spreadsheets/d/1ptdPEHeSkVTRmEae9KwsrnE5ED-u1bK0OwC79hWoOTg/edit?usp=sharing)
[Data Model](https://miro.com/app/board/o9J_lQoNpNI=/)

## How to run the application

1. Run `docker-compose up` to run Postgres
2. Run `bundle exec rails s` to run the app

## Database setup

Run `bundle exec rails db:create db:migrate` to create the database and the database tables
Run `bundle exec rails db:seed` to create users with tasks
