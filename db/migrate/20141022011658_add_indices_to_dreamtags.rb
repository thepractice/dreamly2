class AddIndicesToDreamtags < ActiveRecord::Migration
  def change
  	add_index :dreamtags, :dream_id
  	add_index :dreamtags, :hashtag_id
  	add_index :dreamtags, [:dream_id, :hashtag_id], unique: true
  end
end
