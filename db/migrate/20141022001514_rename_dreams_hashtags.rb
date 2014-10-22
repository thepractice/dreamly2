class RenameDreamsHashtags < ActiveRecord::Migration
  def change
  	rename_table :dreams_hashtags, :dreamtags
  end
end
