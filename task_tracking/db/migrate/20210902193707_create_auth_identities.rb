class CreateAuthIdentities < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'auth_identity_providers') THEN
          CREATE TYPE auth_identity_providers AS ENUM ('keepa');
        END IF;
      END $$;
    SQL

    create_table :auth_identities do |t|
      t.string :uid, null: false
      t.string :token, null: false
      t.string :login, null: false
      t.string :provider, null: false
      t.belongs_to :user_account, null: false, foreign_key: true
      t.timestamps
    end
  end

  def down
    drop_table :auth_identities

    execute <<~SQL
      DROP TYPE IF EXISTS auth_identity_providers;
    SQL
  end
end
