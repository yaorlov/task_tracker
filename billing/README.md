# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

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
assign_amount (possibly move to task_price?)
complete_amount (possibly move to task_price?)
has_many :transactions
belongs_to :account

# Cycle
amount (cash the total of transactions)
closed (enum with true of false, make a payout on change to true)
has_many :transactions
belongs_to :billing_account
