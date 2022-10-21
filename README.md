# README

This is a task tracker with additional accounting and analytics functionality.

Created as an education project, showing my capabilities in building asynchronous microservice architecture.
If you want to see project evolution please go to [closed pull requests](https://github.com/yaorlov/task_tracker/pulls?q=is%3Apr+is%3Aclosed).

The system was designed in several steps:
1. Split business requirements into `Actor`, `Command`, `Aggregate`, and `Domain Event`.

2. Create the [Data Model](https://miro.com/app/board/o9J_lQoNpNI=/). This step is based on the [Event Storming](https://docs.google.com/spreadsheets/d/1ptdPEHeSkVTRmEae9KwsrnE5ED-u1bK0OwC79hWoOTg/edit?usp=sharing) from step 1.

3. Having the Data Model, I've added [Communications flow](https://miro.com/app/board/o9J_lQoaHbE=/) and split the application into services.

## Microservices

### Auth service
Used for users management and oAuth for all services. Available for admins only.

### Task Tracking service
Used for tasks management and tasks-related notifications. Available for all users.

### Billing service
Responsible for salaries calculations and billing dashboard. Available for admins and finance specialists only.

### Analytics service
Responsible for analytics dashboard for admins.

## Routes

```
Auth service
http://localhost:3000 - main
http://localhost:3000/oauth/applications - oAuth app managment

Task Tracking service
http://localhost:5000 - main
http://localhost:5000/login - oAuth login

Billing service
http://localhost:4000 - main
http://localhost:4000/login - oAuth login

Analytics service
http://localhost:7000 - main
http://localhost:7000/login - oAuth login
```

## How to run the applications

1. Run `docker-compose up` to run Postgres and Kafka
2. Start the microservices. Please check the README files in every microservice directory for more details.

## Communications

Vanilla HTTP is used for sync communications. Kafka with schema registry is used for async communications.
## Databases setup

Every microservice is using Postgres as the database. Please check the README files in every microservice directory for more details on database setup.

## K8s
`minikube` and `tilt` are required to run services in local k8s cluster. After the dependencies are installed run:
```bash
minikube start
tilt up
```
To delete resources created by 'tilt up' run:
```bash
tilt down
```
