class ChangeRatingToDecimal < ActiveRecord::Migration
  def change
  	remove_column :dreams, :rating
  	add_column :dreams, :rating, :decimal, default: 0
  end
end
