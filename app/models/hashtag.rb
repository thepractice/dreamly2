class Hashtag < ActiveRecord::Base
	include FriendlyId

	friendly_id :name
	validates_format_of :name, :with => /\A[a-z0-9]+\z/i

	has_many :dreamtags
	has_many :dreams, through: :dreamtags

end
