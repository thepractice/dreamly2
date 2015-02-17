class HashtagsController < ApplicationController

	def index
		@hashtags = Hashtag.all.order('dreams_count DESC').where('dreams_count > 0')

		@hashtag_total = 0

#		@hashtag_words = []
		@hashtags.each do |hashtag|
			@hashtag_total = @hashtag_total + hashtag.dreams.length
#			@hashtag_words.push([hashtag.name, hashtag.dreams.length])
		end
		
	end

	def show
		@hashtag = Hashtag.friendly.find(params[:id])

		if params[:impression].present?
			@dreams_raw = @hashtag.dreams.regular.impression(params[:impression])
		else
			@dreams_raw = @hashtag.dreams.regular
		end

		if params[:onlyme]
			@dreams_raw = @dreams_raw.where(user: current_user)
		end
		
		@dreams = @dreams_raw.paginate(page: params[:page])

	# Graph logic

		@word_count = Hash.new
		# Create hash of word frequencies in all relevant dreams
		@dreams_raw.each do |dream|
			if (dream.private == false) || dream.user = current_user
				dream.word_freq.each do |stem, info_array|
					if @word_count[info_array[0]] == nil
						@word_count[info_array[0]] = { freq: info_array[1], dream_ids: [dream.id] }
					else
						@word_count[info_array[0]][:freq] += info_array[1]
						@word_count[info_array[0]][:dream_ids].push(dream.id)
					end
				end
			end
		end
		# Create hash with key = word_id, and v = freq, to be sortable
		@word_count_sort = Hash.new(0)
		@word_count.each do |k, v|
			@word_count_sort[k] = v[:freq]
		end
		
		@word_count_sort = @word_count_sort.sort_by { |k, v| v }
		@word_count_sort.reverse!

		if params[:graph]
			@min_words_constant = 15
			@min_assocs_constant = 2
		else
			@min_words_constant = 5
			@min_assocs_constant = 2
		end		

		@nodes = Array.new
		@min_words = [@word_count.length, @min_words_constant].min
		@min_words.times do |n|
			@nodes.push(@word_count_sort[n][0])			#@word_count_sort has become an array.
		end

		@links = Array.new

		@min_words.times do |n|
			@word_object_id = @nodes[n]
			@word_object_assocs = Hash.new(0)
			@word_object_dreams = @word_count[@word_object_id][:dream_ids]

			@word_object_dreams.each do |dream_id|
				Dream.find(dream_id).word_freq.each do |stem, info_array|
					if info_array[0] != @word_object_id
						@word_object_assocs[info_array[0]] += info_array[1]
					end
				end
			end

			@word_object_assocs = Hash[@word_object_assocs.sort_by{|k, v| v}.reverse]
			@min_assocs = [@word_object_assocs.length, @min_assocs_constant].min
			@min_assocs.times do |i|
				if @nodes.include? @word_object_assocs.keys[i]		# if the association is already a node
					@links.push([@nodes.index(@word_object_id), @nodes.index(@word_object_assocs.keys[i])])	# write the link
				else @nodes.include? @word_object_assocs.keys[i]		
					@nodes.push(@word_object_assocs.keys[i])
					@links.push([@nodes.index(@word_object_id), @nodes.index(@word_object_assocs.keys[i])])
				end
			end
		end


		@node_text = "["
		@nodes.each do |word_id|

			@node_text += "{\"name\":\"#{word_id}\",\"value\":#{@word_count[word_id][:freq]}},"
		end
		@node_text = @node_text[0..-2] unless @nodes.empty?				# remove extra comma

		@node_text += "]"

		@link_text = "["
		@links.each do |link|
			@link_text += "{\"source\":#{link[0]},\"target\":#{link[1]}},"
		end

		@link_text = @link_text[0..-2] unless @links.empty?		# remove extra comma

		@link_text += "]"

		@graph_text = "{\"nodes\":#{@node_text},\"links\":#{@link_text}}"	

	end

end