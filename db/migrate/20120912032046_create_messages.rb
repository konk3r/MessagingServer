class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.datetime :sent_time
      t.datetime :received_time
      t.datetime :last_updated
      t.string :text
      t.boolean :deleted
      t.references :sender
      t.references :receiver
      
    end
    add_index :messages, :sender_id
    add_index :messages, :receiver_id
  end
  
  def self.down
    drop_table :messages
  end
end
