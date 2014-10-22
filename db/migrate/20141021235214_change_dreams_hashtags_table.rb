class ChangeDreamsHashtagsTable < ActiveRecord::Migration
  def change
  	change_table :dreams_hashtags, id: true do |t|
  		t.timestamps
  	end
  end
end
