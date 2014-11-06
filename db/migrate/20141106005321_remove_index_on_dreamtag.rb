class RemoveIndexOnDreamtag < ActiveRecord::Migration
  def change
  	remove_index :dreamtags, [:dream_id, :hashtag_id]
  end
end
