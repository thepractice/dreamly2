class DreamHashtags < ActiveRecord::Migration
  def change
  	create_table :dreams_hashtags, id: false do |t|
  		t.belongs_to :dream
  		t.belongs_to :hashtag
  	end
  end
end
