# frozen_string_literal: true

puts 'Clearing database...'
Account.destroy_all
Doorkeeper::Application.destroy_all

puts 'Creating users...'
FactoryBot.create(:account, email: 'admin@test.com', role: 'admin', password: '7_777_777')
FactoryBot.create(:account, email: 'manager@test.com', role: 'manager', password: '7_777_777')
FactoryBot.create(:account, email: 'finance@test.com', role: 'finance', password: '7_777_777')
FactoryBot.create(:account, email: 'worker@test.com', role: 'worker', password: '7_777_777')

oauth_apps = []

puts 'Creating OAuth apps...'
oauth_apps << Doorkeeper::Application.create!(
  name: 'task_tracking',
  redirect_uri: "http://localhost:#{ENV.fetch('TASK_TRACKING_APP_PORT')}/auth/keepa/callback",
  scopes: 'public write'
)
oauth_apps << Doorkeeper::Application.create!(
  name: 'billing',
  redirect_uri: "http://localhost:#{ENV.fetch('BILLING_APP_PORT')}/auth/keepa/callback",
  scopes: 'public write'
)
oauth_apps << Doorkeeper::Application.create!(
  name: 'analytics',
  redirect_uri: "http://localhost:#{ENV.fetch('ANALYTICS_APP_PORT')}/auth/keepa/callback",
  scopes: 'public write'
)

puts "== OAuth Credentials =="
oauth_apps.each do |app|
  puts "#{app.name} application:"
  puts "redirect_uri: #{app.redirect_uri}"
  puts "uid ('AUTH_KEY' env var): #{app.uid}"
  puts "secret ('AUTH_SECRET' env var): #{app.secret}"
  puts "====================="
end


