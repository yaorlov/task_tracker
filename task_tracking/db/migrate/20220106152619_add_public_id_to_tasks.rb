class AddPublicIdToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :public_id, :string, null: false, default: 'gen_random_uuid()'
  end
end
