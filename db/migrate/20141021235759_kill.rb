class Kill < ActiveRecord::Migration
  def change
  	drop_table :dreams_hashtags
  	create_table :dreams_hashtags do |t|
  		t.belongs_to :dream 
  		t.belongs_to :hashtag 
  		t.timestamps
  	end
  end
end
