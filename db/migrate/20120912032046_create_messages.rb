class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.datetime :sent_at
      t.datetime :received_at
      t.string :text
      t.boolean :deleted
      t.boolean :private
      t.string :message_type
      t.string :media_uri
      t.references :sender
      t.references :receiver
      
      t.timestamps
    end
    add_index :messages, :sender_id
    add_index :messages, :receiver_id
  end
  
  def self.down
    drop_table :messages
  end
end
