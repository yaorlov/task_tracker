class CreateUserAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :user_accounts do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.timestamps
    end

    add_index :user_accounts, :email, unique: true
  end
end
