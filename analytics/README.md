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
redirect URI: http://localhost:6000/auth/keepa/callback
scopes: public write
```
3. Copy `UID` to `AUTH_KEY` env variable
4. Copy `Secret` to `AUTH_SECRET` env variable

=========================================

TODO:
1. Analytics Service can accept TaskCreated and TaskUpdated in different order. If update is received first, we create the task. Then we add missing fields when TaskCreated is received.
Video: https://youtu.be/1jkqk-7Cckk?t=4537
2. In Analytics Service persist raw events + data for every dashboard. Raw events are needed for new dashboards or to modify an existing one.
Video: https://youtu.be/hW12Tk4UgnA?t=3004

How to deprecate schema versions: https://youtu.be/1jkqk-7Cckk?t=5756
