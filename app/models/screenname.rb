class Screenname < ActiveRecord::Base

	belongs_to :user
	has_many :dreamscreennames
	has_many :dreams, through: :dreamscreennames

end
