class AddWordFreqToDreams < ActiveRecord::Migration
  def change
    add_column :dreams, :word_freq, :text
  end
end
