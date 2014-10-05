class CreateComments < ActiveRecord::Migration
  def change
  	create_table :comments do |t|
  		t.boolean :private
  		t.text :body

  		t.references :dream, index: true
  		t.references :user, index: true

  		t.timestamps
  	end
  end
end
