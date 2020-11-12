class CreateStreamSnapshots < ActiveRecord::Migration[6.0]
  def change
    create_table :stream_snapshots do |t|
      t.string :stream_name
      t.string :event_id
      t.integer :version
      t.text :data

      t.timestamps
    end
    add_index :stream_snapshots, :stream_name
  end
end
