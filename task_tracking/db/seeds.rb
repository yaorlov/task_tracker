# frozen_string_literal: true

Account.where.missing(:auth_identities).find_each do |account|
  FactoryBot.create_list(:task, 3, assignee: account)
end
