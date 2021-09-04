class UpdateUserAccounts < ActiveRecord::Migration[6.1]
  def up
    rename_table :user_accounts, :accounts
    rename_column :auth_identities, :user_account_id, :account_id
    rename_column :tasks, :user_account_id, :account_id
    execute <<~SQL
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'foo_bar_enum_status') THEN
          CREATE TYPE account_roles AS ENUM ('admin', 'manager', 'finance', 'worker');
        END IF;
      END $$;
    SQL
    add_column :accounts, :role, :account_roles, null: false, default: 'worker'
    add_column :accounts, :full_name, :string, null: false
    add_column :accounts, :public_id, :string, null: false
    remove_column :accounts, :first_name
    remove_column :accounts, :last_name
  end

  def down
    remove_column :accounts, :role
    remove_column :accounts, :full_name
    remove_column :accounts, :public_id
    add_column :accounts, :first_name, :string, null: false
    add_column :accounts, :last_name, :string, null: false
    execute <<~SQL
      DROP TYPE IF EXISTS account_roles;
    SQL
    rename_table :accounts, :user_accounts
    rename_column :auth_identities, :account_id, :user_account_id
    rename_column :tasks, :account_id, :user_account_id
  end
end
