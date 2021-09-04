class CreateAuthIdentities < ActiveRecord::Migration[6.1]
  def change
    create_table :auth_identities do |t|
      t.string :uid, null: false
      t.string :token, null: false
      t.string :login, null: false
      t.string :provider, null: false
      t.belongs_to :user_account, null: false, foreign_key: true
      t.timestamps
    end
  end
end
