class Word < ActiveRecord::Base
	serialize :dreams, Array
end
