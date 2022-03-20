class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.text :description, null: false
      t.integer :status, null: false
      t.uuid :public_id, null: false
      t.integer :assign_price, null: false
      t.integer :complete_price, null: false
      t.belongs_to :account, null: false, foreign_key: true
      t.timestamps
    end
  end
end
