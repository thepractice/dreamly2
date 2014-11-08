class Dreamtag < ActiveRecord::Base
	belongs_to :dream 
	belongs_to :hashtag, :counter_cache => :dreams_count
end