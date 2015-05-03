class ChangeComments < ActiveRecord::Migration
  def change
  	drop_table :comments
  	create_table :comments do |t|
  		t.boolean :private
  		t.text :body
  		t.integer :user_id
  		t.references :commentable, polymorphic: true, index: true
  		t.timestamps null: false

  	end
  end
end
