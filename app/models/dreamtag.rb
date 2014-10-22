class Dreamtag < ActiveRecord::Base
	belongs_to :dream 
	belongs_to :hashtag
end