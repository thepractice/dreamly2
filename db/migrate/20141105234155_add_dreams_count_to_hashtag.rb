class AddDreamsCountToHashtag < ActiveRecord::Migration
  def change
  	add_column :hashtags, :dreams_count, :integer, default: 0
  	add_index :hashtags, :dreams_count
  end
end
