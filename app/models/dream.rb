class Dream < ActiveRecord::Base
	belongs_to :user
	default_scope -> { order('dreamed_on DESC') }
	validates :body, presence: true
	validates :user_id, presence: true

#	after_save :gather_words

	protected

		def gather_words
			body = self.body
			words = body.split(/\W+/)								# Split dream body into array of words
			freqs = Hash.new(0)											# Instantiate new hash to hold unique word frequencies
			words.each { |word| freqs[word] += 1 }	# Iterate through raw words array, if freqs[word] == nil, create this
																							# key-value pair with value of 1, else increment value by 1.
			freqs = freqs.sort_by { |x, y| y }			# Sort by value (count)
			freqs.reverse!													# Put in descending order

			user_words = self.user.word_freq

			freqs.each do |word, frequency|		
				# Add unique words/frequencies to global Word table.										
				word_record = Word.find_or_create_by(name: word)
				word_record.global_count += frequency
				word_record.save

				# Add unique word ids/frequencies to User word_freq hash. Currently hacky: default value of hash should be 0, not nil.
				if user_words[word_record.id] == nil
					user_words[word_record.id] = frequency
				else
					user_words[word_record.id] += frequency
				end
			end
			user_words = user_words.sort_by { |x, y| y }
			user_words.reverse!
			self.user.save
		end
end
