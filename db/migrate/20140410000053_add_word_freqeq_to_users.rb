class AddWordFreqeqToUsers < ActiveRecord::Migration
  def change
    add_column :users, :word_freq, :text
  end
end
