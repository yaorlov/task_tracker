class CreateCycles < ActiveRecord::Migration[7.0]
  def change
    create_table :cycles do |t|
      t.integer :amount, null: false, default: 0, comment: 'cash the total of cycle transactions'
      t.boolean :closed, null: false, default: false
      t.uuid :public_id, default: 'gen_random_uuid()', null: false
      t.belongs_to :billing_account, null: false, foreign_key: true
      t.timestamps
    end

    add_reference :transactions, :cycle, foreign_key: true
  end
end
