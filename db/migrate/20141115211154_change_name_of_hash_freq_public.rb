class ChangeNameOfHashFreqPublic < ActiveRecord::Migration
  def change
  	remove_column :users, :hash_freq_private
  	add_column :users, :hash_freq_public, :text
  end
end
