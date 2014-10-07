class Comment < ActiveRecord::Base
	belongs_to :user
	belongs_to :dream

	validates :body, presence: true

	scope :regular, -> { order('created_at DESC') }

end
