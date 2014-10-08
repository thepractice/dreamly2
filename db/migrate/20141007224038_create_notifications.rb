class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.references :dream, index: true
      t.boolean :seen

      t.timestamps
    end
  end
end
