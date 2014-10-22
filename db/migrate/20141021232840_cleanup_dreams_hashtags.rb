class CleanupDreamsHashtags < ActiveRecord::Migration
  def change
  	remove_column :dreams, :hashtags
  	remove_column :hashtags, :dreams
  end
end
