class AddDreamsCountToScreenNames < ActiveRecord::Migration
  def change
  	add_column :screennames, :dreams_count, :integer, default: 0
  end
end
