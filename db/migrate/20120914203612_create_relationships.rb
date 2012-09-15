class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :user_id
      t.integer :contact_id
      t.integer :partner_id
      t.string :approved

      t.timestamps
    end
    
    add_index :relationships, :user_id
    add_index :relationships, :contact_id
    add_index :relationships, [:user_id, :contact_id], unique: true
  end
end
