class AddIndexBackToDreamtag < ActiveRecord::Migration
  def change
  	add_index :dreamtags, [:dream_id, :hashtag_id], unique: true
  end
end
