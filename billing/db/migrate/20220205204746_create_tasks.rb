class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.text :description, null: false
      t.integer :status, null: false
      t.uuid :public_id, default: 'gen_random_uuid()', null: false
      t.integer :assign_price
      t.integer :complete_price
      t.belongs_to :account, null: false, foreign_key: true
      t.timestamps
    end
  end
end