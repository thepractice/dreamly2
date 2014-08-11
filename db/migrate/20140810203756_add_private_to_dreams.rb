class AddPrivateToDreams < ActiveRecord::Migration
  def change
  	add_column :dreams, :private, :boolean, default: false
  end
end
