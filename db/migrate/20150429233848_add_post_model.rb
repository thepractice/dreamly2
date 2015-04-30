class AddPostModel < ActiveRecord::Migration
  def change
  	create_table :articles do |t|
  		t.string :title
  		t.text :body
  		t.integer :user_id
  		t.boolean :published
  		t.text :tags

  		t.timestamps
  	end
  end
end
