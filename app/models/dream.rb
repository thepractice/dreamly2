class Dream < ActiveRecord::Base
	belongs_to :user
	default_scope -> { order('dreamed_on DESC') }
	validates :body, presence: true
	validates :user_id, presence: true
end
