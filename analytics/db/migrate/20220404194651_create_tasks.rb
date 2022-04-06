class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.text :description, null: false
      t.uuid :public_id, null: false
      t.integer :complete_price
      t.timestamp :completed_at
      t.timestamps
    end
  end
end
