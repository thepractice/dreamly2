class AddNamesToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :names, :text
  end
end
