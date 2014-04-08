class AddDreamedOnToDreams < ActiveRecord::Migration
  def change
    add_column :dreams, :dreamed_on, :date
  end
end
