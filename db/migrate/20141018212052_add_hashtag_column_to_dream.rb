class AddHashtagColumnToDream < ActiveRecord::Migration
  def change
  	add_column :dreams, :hashtags, :text
  end
end
