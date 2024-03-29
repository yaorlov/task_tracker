class CreateBillingAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :billing_accounts do |t|
      t.integer :amount, null: false, default: 0, comment: 'Cash the total of transactions'
      t.uuid :public_id, default: 'gen_random_uuid()', null: false
      t.belongs_to :account, null: false, foreign_key: true
      t.timestamps
    end
  end
end
