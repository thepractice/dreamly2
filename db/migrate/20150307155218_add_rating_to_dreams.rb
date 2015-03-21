class AddRatingToDreams < ActiveRecord::Migration
  def change
  	add_column :dreams, :rating, :integer, default: 0
  end
end
