class AddDreamsToWords < ActiveRecord::Migration
  def change
    add_column :words, :dreams, :text
  end
end
