class AddPublicTitleToDreams < ActiveRecord::Migration
  def change
  	add_column :dreams, :public_title, :string
  end
end
