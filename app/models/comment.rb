class Comment < ActiveRecord::Base
	belongs_to :user
	belongs_to :commentable, polymorphic: true

	validates :body, presence: true

	scope :regular, -> { order('created_at DESC') }

end
