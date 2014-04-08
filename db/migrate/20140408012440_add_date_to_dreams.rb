class AddDateToDreams < ActiveRecord::Migration
  def change
    add_column :dreams, :date, :date
  end
end
