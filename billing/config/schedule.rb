# Use this file to easily define all of your cron jobs.
#
# Learn more: http://github.com/javan/whenever

every :weekday, at: '6pm' do
  rake 'close_billing_cycles'
end
