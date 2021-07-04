# README

[Event Storming](https://docs.google.com/spreadsheets/d/1ptdPEHeSkVTRmEae9KwsrnE5ED-u1bK0OwC79hWoOTg/edit?usp=sharing)
[Data Model](https://miro.com/app/board/o9J_lQoNpNI=/)
[Domains and Communications](https://miro.com/app/board/o9J_lQoaHbE=/)

## How to run the application

1. Run `docker-compose up` to run Postgres
2. Run `bundle exec rails s` to run the app

## Database setup

Run `bundle exec rails db:create db:migrate` to create the database and the database tables
Run `bundle exec rails db:seed` to create users with tasks

## Routes

```
auth service
localhost:3000 - main
localhost:3000/oauth/applications - oauth app managment

task_tracking service
localhost:5000 - main
# localhost:5000/auth/login - oauth login
```
