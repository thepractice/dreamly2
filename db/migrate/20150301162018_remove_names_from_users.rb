class RemoveNamesFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :names

  	create_table :screennames do |t|
  		t.string :name
  		t.integer :user_id
  		t.timestamps
  	end

  	create_table :dreamscreennames do |t|
  		t.belongs_to :dream
  		t.belongs_to :screenname
  		t.timestamps
  	end

  end
end
