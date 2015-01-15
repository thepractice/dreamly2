class Emotion < ActiveRecord::Base
	has_many :dreamemotions
	has_many :dreams, through: :dreamemotions
end
