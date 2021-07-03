class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {
    admin: 'admin',
    manager: 'manager',
    finance: 'finance',
    worker: 'worker'
  }

  after_create do
    event = {
      event_name: 'AccountCreated',
      data: {
        public_id: public_id
      }
    }

    Producer.call(event.to_json, topic: 'accounts-stream')
  end
end
