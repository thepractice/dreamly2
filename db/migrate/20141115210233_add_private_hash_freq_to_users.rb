class AddPrivateHashFreqToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :hash_freq_private, :text
  end
end
