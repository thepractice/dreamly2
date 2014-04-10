class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :name
      t.integer :global_count, default: 0

      t.timestamps
    end
  end
end
