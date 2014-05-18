class AddGraphToUsers < ActiveRecord::Migration
  def change
    add_column :users, :graph, :text
  end
end
