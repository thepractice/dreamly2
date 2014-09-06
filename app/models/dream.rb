class Dream < ActiveRecord::Base
	serialize :word_freq, Hash

	include ActionView::Helpers::TextHelper
	include ActionView::Helpers::SanitizeHelper

	belongs_to :user, counter_cache: :dream_count
	default_scope -> { order('dreamed_on DESC, created_at DESC') }
	validates :body, presence: true
	validates :user_id, presence: true

	scope :impression, -> (min_impression) { where("impression >= ?", min_impression) }

	before_update :reverse_dream
	before_save :init_data
	after_save :gather_words
	after_save :update_graph
	after_save :update_graph_public
	before_destroy :reverse_dream
	before_destroy :update_graph

	protected

		def init_data
			self.dreamed_on ||= Date.today if new_record?
		end


		def gather_words

			stopwords = ['walking','right','back','outside','doesn','dream','up','down','something','one','go',"re", "ve", "a","able","about","across","after","all","almost","also","am","among","an","and","any","are","as","at","be","because","been","but","by","can","cannot","could","dear","did","do","does","either","else","ever","every","for","from","get","got","had","has","have","he","her","hers","him","his","how","however","i","if","in","into","is","it","its","just","least","let","like","likely","may","me","might","most","must","my","neither","no","nor","not","of","off","often","on","only","or","other","our","own","rather","said","say","says","she","should","since","so","some","than","that","the","their","them","then","there","these","they","this","tis","to","too","twas","us","wants","was","we","were","what","when","where","which","while","who","whom","why","will","with","would","yet","you","your","ain't","aren't","can't","could've","couldn't","didn't","doesn't","don't","hasn't","he'd","he'll","he's","how'd","how'll","how's","i'd","i'll","i'm","i've","isn't","it's","might've","mightn't","must've","mustn't","shan't","she'd","she'll","she's","should've","shouldn't","that'll","that's","there's","they'd","they'll","they're","they've","wasn't","we'd","we'll","we're","weren't","what'd","what's","when'd","when'll","when's","where'd","where'll","where's","who'd","who'll","who's","why'd","why'll","why's","won't","would've","wouldn't","you'd","you'll","you're","you've"]

			body = self.body
			words = body.split(/\W+/)								# Split dream body into array of words

			if self.title.blank?										# Sets title if no title.
				self.title = sanitize(self.body, tags: []).truncate(20, separator: ' ', omission: '')
				self.update_columns(title: self.title)
			end

			freqs = Hash.new(0)											# Instantiate new hash to hold unique word frequencies
			words.each do |word|
				word.downcase!
				if ( stopwords.exclude? word ) && word.length > 1
					freqs[word] += 1 	# Iterate through raw words array, if freqs[word] == nil, create this
				end
			end																				# key-value pair with value of 1, else increment value by 1.
			freqs = freqs.sort_by { |x, y| y }			# Sort by value (count)
			freqs.reverse!													# put in descending order

			user_words = self.user.word_freq
			user_words_public = self.user.word_freq_public

			freqs.each do |word, frequency|

				# Add unique words/frequencies to global Word table.										
				word_record = Word.find_or_create_by(name: word)
				word_record.global_count += frequency
				word_record.dreams.push(self.id)	# Add dream_id to Word.dreams array
				word_record.save


				# Add word id/frequency to Dream Word_freq hash.
				self.word_freq[word_record.id] = frequency

				# Add unique word ids/frequencies to User word_freq hash. Currently hacky: default value of hash should be 0, not nil.
			#	if user_words[word_record.id] == nil
			#		user_words[word_record.id] = frequency
			#	else
			#		user_words[word_record.id] += frequency
			#	end

				# Add unique word ids/frequencies to User word_freq hash. Currently hacky: default value of hash should be 0, not nil.
				if user_words[word_record.id] == nil
					user_words[word_record.id] = { freq: frequency, dream_ids: [self.id] }
				else
					user_words[word_record.id][:freq] += frequency
					user_words[word_record.id][:dream_ids].push(self.id)
				end

				if self.private == false
					# Add unique word ids/frequencies to User word_freq_public hash. Currently hacky: default value of hash should be 0, not nil.
					if user_words_public[word_record.id] == nil
						user_words_public[word_record.id] = { freq: frequency, dream_ids: [self.id] }
					else
						user_words_public[word_record.id][:freq] += frequency
						user_words_public[word_record.id][:dream_ids].push(self.id)
					end
				end

			end
			user_words = Hash[user_words.sort_by { |k, v| v[:freq] }.reverse]
			user_words_public = Hash[user_words_public.sort_by { |k, v| v[:freq] }.reverse]
			self.user.update_columns(word_freq: user_words)
			self.user.update_columns(word_freq_public: user_words_public)
		#	self.user.save   	# save User to save User word_freq hash
			self.update_columns(word_freq: self.word_freq)		# save Dream word_freq hash
		end

		def update_graph
	#		nodes = "["
	#		5.times do |n|
	#			nodes += "{'word_id':#{self.user.word_freq.keys[n]},'value':#{self.user.word_freq.values[n]}}"
	#			nodes += "," unless n == 4
	#		end
	#		nodes += "]"

			# Load the nodes array with ids of most frequent words.
			nodes = Array.new
			min_words = [self.user.word_freq.length, 5].min
			min_words.times do |n|
				nodes.push(self.user.word_freq.keys[n])
			end

			links = Array.new



			min_words.times do |n|


				word_object_assocs = Hash.new(0)

				word_object_id = self.user.word_freq.keys[n]
				word_object = Word.find(word_object_id)
				word_object_dreams = self.user.word_freq[word_object_id][:dream_ids]

				# Set array with dream_ids of user which contain word_object
		#		word_object.dreams.each do |dream_id|
		#			if Dream.find(dream_id).user_id == self.user.id
		#				word_object_dreams.push(dream_id)
		#			end
		#		end

	

				word_object_dreams.each do |dream_id|														# Iterate through each dream
					Dream.find(dream_id).word_freq.each do |word_id, frequency|		# Iterate through each unique word
						if word_id != word_object_id
							word_object_assocs[word_id] += frequency									# Add word count to word_object_assocs hash
						end
					end
				end

				word_object_assocs = Hash[word_object_assocs.sort_by{ |k, v| v }.reverse]
				min_assocs = [word_object_assocs.length, 2].min
				min_assocs.times do |i|
					if nodes.include? word_object_assocs.keys[i]					# if first association is already a node
						links.push([nodes.index(word_object_id), nodes.index(word_object_assocs.keys[i])])				# write a link
					else
						nodes.push(word_object_assocs.keys[i])
						links.push([nodes.index(word_object_id), nodes.index(word_object_assocs.keys[i])])
					end
				end

		#		word_object_dreams.clear
		#		word_object_assocs.clear
			end

			node_text = "["
			nodes.each do |word_id|
				node_text += "{\"name\":\"#{Word.find(word_id).name}\",\"value\":#{self.user.word_freq[word_id][:freq]}},"
			end
			node_text = node_text[0..-2] unless nodes.empty?				# remove extra comma
			node_text += "]"

			link_text = "["
			links.each do |link|
				link_text += "{\"source\":#{link[0]},\"target\":#{link[1]}},"
			end
			link_text = link_text[0..-2] unless links.empty?		# remove extra comma
			link_text += "]"

			graph_text = "{\"nodes\":#{node_text},\"links\":#{link_text}}"
			self.user.update_columns(graph: graph_text)
		end

		def update_graph_public
			nodes = Array.new
			min_words = [self.user.word_freq_public.length, 5].min
			min_words.times do |n|
				nodes.push(self.user.word_freq_public.keys[n])
			end

			links = Array.new



			min_words.times do |n|


				word_object_assocs = Hash.new(0)

				word_object_id = self.user.word_freq_public.keys[n]
				word_object = Word.find(word_object_id)
				word_object_dreams = self.user.word_freq_public[word_object_id][:dream_ids]

				word_object_dreams.each do |dream_id|														# Iterate through each dream
					Dream.find(dream_id).word_freq.each do |word_id, frequency|		# Iterate through each unique word
						if word_id != word_object_id
							word_object_assocs[word_id] += frequency									# Add word count to word_object_assocs hash
						end
					end
				end

				word_object_assocs = Hash[word_object_assocs.sort_by{ |k, v| v }.reverse]
				min_assocs = [word_object_assocs.length, 2].min
				min_assocs.times do |i|
					if nodes.include? word_object_assocs.keys[i]					# if first association is already a node
						links.push([nodes.index(word_object_id), nodes.index(word_object_assocs.keys[i])])				# write a link
					else
						nodes.push(word_object_assocs.keys[i])
						links.push([nodes.index(word_object_id), nodes.index(word_object_assocs.keys[i])])
					end
				end
			end

			node_text = "["
			nodes.each do |word_id|
				node_text += "{\"name\":\"#{Word.find(word_id).name}\",\"value\":#{self.user.word_freq_public[word_id][:freq]}},"
			end
			node_text = node_text[0..-2] unless nodes.empty?				# remove extra comma
			node_text += "]"

			link_text = "["
			links.each do |link|
				link_text += "{\"source\":#{link[0]},\"target\":#{link[1]}},"
			end
			link_text = link_text[0..-2] unless links.empty?		# remove extra comma
			link_text += "]"

			graph_text = "{\"nodes\":#{node_text},\"links\":#{link_text}}"
			self.user.update_columns(graph_public: graph_text)
		end

		def reverse_dream

			user_words = self.user.word_freq
			user_words_public = self.user.word_freq_public

			# Iterate through dream word frequency hash
			self.word_freq.each do |word_id, freq|
				word_record = Word.find(word_id)
				word_record.global_count -= freq 		# Decrement word record global count
				word_record.dreams.delete(self.id)	# Remove dream id from word_record dream array

				user_words[word_record.id][:freq] -= freq 							# Decrement User word_freq count
				user_words[word_record.id][:dream_ids].delete(self.id)	# Remove dream_id from User word_freq hash

				if user_words[word_record.id][:freq] == 0		# if User word_freq = 0, delete the listing from hash
					user_words.delete(word_record.id)
				end

				user_words_public[word_record.id][:freq] -= freq 							# Decrement User word_freq_public count
				user_words_public[word_record.id][:dream_ids].delete(self.id)	# Remove dream_id from user_words_public hash

				if user_words_public[word_record.id][:freq] == 0		# if User word_freq = 0, delete the listing from hash
					user_words_public.delete(word_record.id)
				end				

				self.user.update_columns(word_freq: user_words)			# Save User word_freq hash
				self.user.update_columns(word_freq_public: user_words_public)			# Save User word_freq_public hash

				if word_record.global_count == 0		# if word record global count = 0, delete the word record
					word_record.destroy
				else
					word_record.save
				end
								
			end

			self.word_freq.clear			# Clear the Dream word_freq hash

		end


end