class Hashtag < ActiveRecord::Base
	serialize :dreams, Array
	include FriendlyId

	friendly_id :name
	validates_format_of :name, :with => /\A[a-z0-9]+\z/i
end
