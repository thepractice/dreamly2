class Dream < ActiveRecord::Base
	serialize :word_freq, Hash

	include ActionView::Helpers::TextHelper
	include ActionView::Helpers::SanitizeHelper
	include Twitter::Extractor
	include Twitter::Autolink
#	html = auto_link("link @user, please #request")

	belongs_to :user, counter_cache: :dream_count
	has_many :comments, dependent: :destroy
	has_many :notifications, dependent: :destroy
	has_many :dreamtags
	has_many :hashtags, through: :dreamtags

	acts_as_votable

	validates :body, presence: true
	validates :user_id, presence: true

#	default_scope -> { order('dreamed_on DESC, created_at DESC') }
	scope :regular, -> { order('created_at DESC') }
	scope :chronological, -> { order('dreamed_on DESC, created_at DESC') }
	scope :impression, -> (min_impression) { where("impression >= ?", min_impression) }





	before_update :reverse_dream
	before_save :init_data
	after_save :set_hashtags
	after_save :gather_words
	#after_save :update_graph
	#after_save :update_graph_public
	before_destroy :reverse_dream
	#before_destroy :update_graph

	include PgSearch
	multisearchable against: [:title, :body]
	pg_search_scope :search, against: [:title, :body],
		using: {tsearch: {dictionary: "english"}}



	def self.text_search(query)
		if query.present?
			search(query)
		else
			scoped
		end
	end

	def Dream.from_users_followed_by(user)
		following_ids = "SELECT followed_id FROM relationships
										 WHERE follower_id = :user_id"
		where("user_id IN (#{following_ids}) AND private = false OR user_id = :user_id", user_id: user)
	end


	protected

		def init_data
			self.dreamed_on ||= Date.today if new_record?

	#		hashtags = extract_hashtags(self.body)

	#		self.hashtags = []    # Clear the Dream hashtag column

	#		hashtags.each do |hashtag|     # Create or update the Hashtag model
	#			hashtag_record = Hashtag.find_or_create_by(name: hashtag)
	#			hashtag_record.dreams.push(self.id)
	#			hashtag_record.save

	#			self.hashtags.push(hashtag_record.id)    # Add hashtag model ID to Dream model hashtag column
	#		end		

		end

		def set_hashtags

			hashtags = extract_hashtags(self.body).uniq

			user_hashes = self.user.hash_freq

			hashtags.each do |hashtag|
				hashtag.downcase!   
				hashtag_record = Hashtag.find_or_create_by(name: hashtag)   # Create or update the Hashtag model

				if self.dreamtags.where(hashtag_id: hashtag_record.id).empty?		# Avoid double-creating the dreamtag (? needed)
					self.dreamtags.create(hashtag_id: hashtag_record.id)   # Create the intermediate relationship
				end

				if self.private == false
					hashtag_record.dreams_count = hashtag_record.dreams_count + 1
					hashtag_record.save

					if self.user.hash_freq_public[hashtag_record.id] == nil
						self.user.hash_freq_public[hashtag_record.id] = 1
					else
						self.user.hash_freq_public[hashtag_record.id] += 1
					end

				end	

				if user_hashes[hashtag_record.id] == nil
					user_hashes[hashtag_record.id] = 1
				else
					user_hashes[hashtag_record.id] += 1
				end

				user_hashes = Hash[user_hashes.sort_by { |k, v| v }.reverse]
				self.user.hash_freq_public = Hash[self.user.hash_freq_public.sort_by { |k, v| v }.reverse]
				self.user.update_columns(hash_freq: user_hashes, hash_freq_public: self.user.hash_freq_public)

			end		

			
			




		end


		def gather_words

			stopwords = ['starts','someone','gets','saying','kind','others','ll','soon','large','huge', 'talking','ask','start','agree','getting','walk','find','tried','put','couple','quite','ready','goes','anyone','everyone','didn','large','until', 'little','big','much','small','above','over','more','onto','even','suddenly','actually','years', 'same','found','both','away',  'asks', 'wanted','felt','sort','front','each','few','still','woke','came','thing' 'talking','sitting','through','lot','myself','good' 'over','room', 'thought', 'person', 'leave','need','last','night', 'before','now','want','well','look','looks','looked', 'area','show','comes','land',  'type','tell','two','take','left','place','know',  'came','started','knew','think','people','went','time','very','another','first','don' , 'real', 'life','really', 'looked','told','around','next','saw','way','going','see','being','out','remember', 'thee', 'thy', 'thou', 'though', 'thine', 'walking','right','back','outside','doesn','dream','up','down','something','one','go',"re", "ve", "a","able","about","across","after","all","almost","also","am","among","an","and","any","are","as","at","be","because","been","but","by","can","cannot","could","dear","did","do","does","either","else","ever","every","for","from","get","got","had","has","have","he","her","hers","him","his","how","however","i","if","in","into","is","it","its","just","least","let","like","likely","may","me","might","most","must","my","neither","no","nor","not","of","off","often","on","only","or","other","our","own","rather","said","say","says","she","should","since","so","some","than","that","the","their","them","then","there","these","they","this","tis","to","too","twas","us","wants","was","we","were","what","when","where","which","while","who","whom","why","will","with","would","yet","you","your","ain't","aren't","can't","could've","couldn't","didn't","doesn't","don't","hasn't","he'd","he'll","he's","how'd","how'll","how's","i'd","i'll","i'm","i've","isn't","it's","might've","mightn't","must've","mustn't","shan't","she'd","she'll","she's","should've","shouldn't","that'll","that's","there's","they'd","they'll","they're","they've","wasn't","we'd","we'll","we're","weren't","what'd","what's","when'd","when'll","when's","where'd","where'll","where's","who'd","who'll","who's","why'd","why'll","why's","won't","would've","wouldn't","you'd","you'll","you're","you've"]

			body = self.body
			words = body.split(/\W+/)								# Split dream body into array of words

			if self.title.blank?										# Sets title if no title.
				self.title = sanitize(self.body, tags: []).truncate(75, separator: ' ', omission: '') + " ..."
				self.update_columns(title: self.title)
			end

			freqs = Hash.new										# Instantiate new hash to hold unique word frequencies
			words.each do |word|
				word.downcase!
				if ( stopwords.exclude? word ) && word.length > 1
					stem = Lingua.stemmer(word)
					if freqs[stem] == nil	# If the stem id not already listed
						freqs[stem] = [word, 1]
					
					else
						freqs[stem][1] + freqs[stem][1] + 1 	
					end
				end
			end	

			freqs = Hash[freqs.sort_by{ |k, v| v[0] }.reverse]	

			self.word_freq = freqs
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

			self.word_freq.clear			# Clear the Dream word_freq hash

			self.hashtags.each do |hashtag|
				
				if self.private == false
					hashtag.dreams_count = hashtag.dreams_count - 1
					hashtag.save
				else
					unless self.user.hash_freq_public[hashtag.id] == nil
						self.user.hash_freq_public[hashtag.id] -= 1
						if self.user.hash_freq_public[hashtag.id] < 1
							self.user.hash_freq_public.delete(hashtag.id)
						end
					end
				end
				if hashtag.dreams.length < 1
					hashtag.destroy
				end
				self.dreamtags.where(hashtag: hashtag).destroy_all

				self.user.hash_freq[hashtag.id] -= 1	# Decrement the User's hash count


			end

		end

end