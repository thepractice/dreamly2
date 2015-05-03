class FixDreams < ActiveRecord::Migration
  def change
  	#add_column :dreams, :user_id, :integer
  	#remove_columns :dreams, :author
  	add_column :articles, :author, :string
  	remove_column :articles, :user_id
  end
end
