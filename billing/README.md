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
name: billing
redirect URI: http://localhost:4000/auth/keepa/callback
scopes: public write
```
3. Copy `UID` to `AUTH_KEY` env variable
4. Copy `Secret` to `AUTH_SECRET` env variable

=================

Events for billing: https://www.youtube.com/watch?v=TU9ykdAY4oo
Domain for billing: https://youtu.be/Q4DM-Yzhdqg?t=3550

# Account (with all roles, as the role can be changed to finance etc.)
has_one :billing_account

# BillingAccount
amount (cash the total of transactions)
has_many :transactions
has_many :cycles
belongs_to :account

# Transaction
debit
credit
type (enum of (task_completed, task_assigned, payout))
belongs_to :billing_account
belongs_to :cycle
belongs_to :task (optional)

# Task
...
assign_amount
complete_amount
has_many :transactions
belongs_to :account

# Cycle
amount (cash the total of transactions for billing cycle)
closed (enum with true of false, make a payout on change to true)
has_many :transactions
belongs_to :billing_account
