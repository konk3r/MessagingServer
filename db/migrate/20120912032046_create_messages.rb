class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.date :times_sent
      t.date :time_received
      t.string :text
      t.boolean :deleted
      t.references :user_from
      t.references :user_to
      
    end
    add_index :messages, :user_from_id
    add_index :messages, :user_to_id
  end
  
  def self.down
    drop_table :messages
  end
end
