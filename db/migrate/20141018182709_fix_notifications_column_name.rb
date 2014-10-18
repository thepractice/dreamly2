class FixNotificationsColumnName < ActiveRecord::Migration
  def change
  	rename_column :notifications, :type, :subject
  end
end
