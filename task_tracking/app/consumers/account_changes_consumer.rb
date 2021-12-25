# frozen_string_literal: true

class AccountChangesConsumer < ApplicationConsumer
  def consume
    params_batch.each do |message|
      puts '-' * 80
      p message
      puts '-' * 80

      account = Account.find_by(public_id: message.payload['data']['public_id'])

      case message.payload['event_name']
      when 'AccountCreated'
        Account.create(message.payload['data'])
      when 'AccountUpdated'
        if account
          account.update(
            full_name: message.payload['data']['full_name']
          )
        end
      when 'AccountDeleted'
        account.destroy if account
      when 'AccountRoleChanged'
        account.update(role: message.payload['data']['role']) if account
      else
        # store events in DB
      end
    end
  end
end
