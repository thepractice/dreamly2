class AddPublicBodyToDream < ActiveRecord::Migration
  def change
  	add_column :dreams, :public_body, :text
  end
end
