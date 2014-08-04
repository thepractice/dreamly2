class AddDreamCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dream_count, :integer, default: 0
    add_index :users, :dream_count
  end
end
