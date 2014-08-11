class ChangeDefaultofImpression < ActiveRecord::Migration
  def change
  	change_column :dreams, :impression, :integer, default: 1
  end
end
