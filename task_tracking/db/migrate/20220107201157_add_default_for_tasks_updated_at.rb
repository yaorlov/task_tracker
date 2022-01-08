class AddDefaultForTasksUpdatedAt < ActiveRecord::Migration[6.1]
  def up
    change_column :tasks, :updated_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" }
  end

  def down
    change_column :tasks, :updated_at, :datetime, null: false, default: nil
  end
end
