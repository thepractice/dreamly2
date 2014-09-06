class AddPublicWordFreqAndGraph < ActiveRecord::Migration
  def change
  	add_column :users, :word_freq_public, :text
  	add_column :users, :graph_public, :text
  end
end
