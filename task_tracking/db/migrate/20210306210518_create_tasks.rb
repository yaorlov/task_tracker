class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.text :description, null: false
      t.integer :status, default: 0, null: false
      t.belongs_to :user_account, null: false, foreign_key: true
      t.timestamps
    end
  end
end
