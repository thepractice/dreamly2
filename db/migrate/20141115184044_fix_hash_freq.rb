class FixHashFreq < ActiveRecord::Migration
  def change
  	add_column :users, :hash_freq, :text
  	remove_column :dreams, :hash_freq
  end
end
