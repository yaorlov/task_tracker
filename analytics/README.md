# README

* Database creation
`bundle exec rails db:create db:migrate:db:seed`

* Run rails and karafka servers
`foreman start`

* How to run the test suite
`bundle exec rspec`

### Setup Auth
1. Go to http://localhost:3000/oauth/applications
2. Create a new oAuth application with:
```
name: analytics
redirect URI: http://localhost:7000/auth/keepa/callback
scopes: public write
```
3. Copy `UID` to `AUTH_KEY` env variable
4. Copy `Secret` to `AUTH_SECRET` env variable
