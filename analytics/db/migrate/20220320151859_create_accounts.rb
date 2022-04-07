class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :full_name, null: false
      t.string :public_id, null: false
      t.string :email, null: false
      t.timestamps
    end

    add_index :accounts, :email, unique: true
  end
end
