class AddImpressionToDreams < ActiveRecord::Migration
  def change
    add_column :dreams, :impression, :integer, default: 0
  end
end
