class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :dream

  scope :regular, -> { order('created_at DESC') }
end
