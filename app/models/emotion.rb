class Emotion < ActiveRecord::Base
	has_many :dreamemotions
	has_many :dreams, through: :dreamemotions

	def self.options_for_select
		order('LOWER(name)').map { |e| [e.name, e.id] }
	end
end
