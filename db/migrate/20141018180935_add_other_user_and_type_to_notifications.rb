class AddOtherUserAndTypeToNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :other_user_id, :integer
  	add_column :notifications, :type, :string
  end
end
