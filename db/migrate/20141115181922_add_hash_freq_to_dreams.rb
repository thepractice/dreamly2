class AddHashFreqToDreams < ActiveRecord::Migration
  def change
  	add_column :dreams, :hash_freq, :text
  end
end
