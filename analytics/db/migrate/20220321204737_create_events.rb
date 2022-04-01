class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :stream_id, null: false, comment: 'public id of the entity/aggregate'
      t.integer :version, null: false, comment: 'used to sort the events of the specific stream'
      t.jsonb :data, null: false
      t.timestamps
    end

    add_index :events, [:stream_id, :version], unique: true
  end
end
