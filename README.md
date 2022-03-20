# README

[Event Storming](https://docs.google.com/spreadsheets/d/1ptdPEHeSkVTRmEae9KwsrnE5ED-u1bK0OwC79hWoOTg/edit?usp=sharing)
[Data Model](https://miro.com/app/board/o9J_lQoNpNI=/)
[Domains and Communications](https://miro.com/app/board/o9J_lQoaHbE=/)

## How to run the applications

1. Run `docker-compose up` to run Postgres and Kafka
2. Run `bundle exec rails s` from `auth` dir to start the Auth service
3. Run `foreman start` from `task_tracking` dir to start Task Tracking service with Kafka consumer

## Databases setup

From `auth` dir:
1. Run `be rails db:drop db:create db:migrate db:seed` to create and seed the database
From `task_tracking` dir:
1. Run `be rails db:create db:migrate` to create the database
2. Start Karafka (`bundle exec karafka s`) to consume accounts stream and create accounts in Task Tracking service DB
3. Run `be rails db:seed` to create tasks for every account

## Routes

```
Auth service
http://localhost:3000 - main
http://localhost:3000/oauth/applications - oauth app managment

Task Tracking service
http://localhost:5000 - main
http://localhost:5000/login - oauth login

Billing service
http://localhost:4000 - main
http://localhost:4000/login - oauth login

Analytics service
http://localhost:6000 - main
http://localhost:6000/login - oauth login
```