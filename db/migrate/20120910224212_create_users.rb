class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.string :device_id
      t.string :api_key
      t.timestamps
    end
  end
  
  def self.down
    drop_table :users
  end
end
