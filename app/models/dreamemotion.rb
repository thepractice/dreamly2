class Dreamemotion < ActiveRecord::Base
	belongs_to :dream
	belongs_to :emotion
end
