class CreateTransactions < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQL
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'transaction_types') THEN
          CREATE TYPE transaction_types AS ENUM ('task_completed', 'task_assigned', 'payout');
        END IF;
      END $$;
    SQL

    create_table :transactions do |t|
      t.integer :debit, null: false, default: 0, comment: 'plus'
      t.integer :credit, null: false, default: 0, comment: 'minus'
      t.uuid :public_id, default: 'gen_random_uuid()', null: false
      t.belongs_to :billing_account, null: false, foreign_key: true
      t.belongs_to :task, foreign_key: true
      t.timestamps
    end

    add_column :transactions, :transaction_type, :transaction_types, null: false
  end

  def down
    drop_table :transactions
    execute <<~SQL
      DROP TYPE IF EXISTS transaction_types;
    SQL
  end
end
