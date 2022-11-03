# frozen_string_literal: true

Account.destroy_all
FactoryBot.create(:account, email: 'admin@test.com', role: 'admin', password: '7_777_777')
FactoryBot.create(:account, email: 'manager@test.com', role: 'manager', password: '7_777_777')
FactoryBot.create(:account, email: 'finance@test.com', role: 'finance', password: '7_777_777')
FactoryBot.create(:account, email: 'worker@test.com', role: 'worker', password: '7_777_777')
