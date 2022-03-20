class AddRoleToAccounts < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_roles') THEN
          CREATE TYPE account_roles AS ENUM ('admin', 'manager', 'finance', 'worker');
        END IF;
      END $$;
    SQL
    add_column :accounts, :role, :account_roles, null: false, default: 'worker'
  end

  def down
    remove_column :accounts, :role
    execute <<~SQL
      DROP TYPE IF EXISTS account_roles;
    SQL
  end
end
