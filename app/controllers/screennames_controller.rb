class ScreennamesController < ApplicationController
	before_filter :correct_user

	def show
		@screenname = Screenname.find(params[:id])
		@dreams = @screenname.dreams

		@filterrific = initialize_filterrific(
			@dreams,
			params[:filterrific],
			select_options: {
				with_emotion_id: Emotion.options_for_select
			},
			default_filter_params: { search: params[:search] },
		) or return

		@dreams = @filterrific.find

		if params[:sort] == 'trending'
			@dreams = @dreams.hot
		elsif params[:sort] == 'submitted'
			@dreams = @dreams.regular
		elsif params[:sort] == 'dreamed'
			@dreams = @dreams.chronological
		else
			@dreams = @dreams.chronological
		end

		@dreams2 = @dreams.paginate(page: params[:page],per_page: 15)
		
		@page_number = params[:page].to_i
		if params[:page].nil?
			@dreams = @dreams.paginate(page: params[:page],per_page: 15)
		elsif params[:page] == 1
			@dreams = @dreams.paginate(page: params[:page],per_page: 15)
		else
			@cumul = @dreams.paginate(page: 1,per_page: 15)
			(@page_number - 1).times do |i|
				@dreams.paginate(page: i + 2,per_page: 15).each do |dream|
					@cumul = @cumul << dream
				end
			end
			@dreams = @cumul
		end

	

		@hashes = Hash.new
		@screennames = Hash.new
		@emotions = Hash.new

		@dreams.each do |dream|
			dream.screennames.each do |screenname|
				if @screennames[screenname.id].nil?
					@screennames[screenname.id] = 1
				else
					@screennames[screenname.id] += 1
				end
			end

			dream.emotions.each do |emotion|
				if @emotions[emotion.id].nil?
					@emotions[emotion.id] = 1
				else
					@emotions[emotion.id] += 1
				end
			end					

			dream.hashtags.each do |hashtag|
				if @hashes[hashtag.id].nil?
					@hashes[hashtag.id] = 1
				else
					@hashes[hashtag.id] += 1
				end
			end
		end

		@screennames = @screennames.sort_by { |k, v| v }
		@screennames.reverse!

		@emotions = @emotions.sort_by { |k, v| v }
		@emotions.reverse!		

		@hashes = @hashes.sort_by { |k, v| v }
		@hashes.reverse!

	# Graph logic

		@word_count = Hash.new
		# Create hash of word frequencies in all relevant dreams
		@dreams.each do |dream|
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

	private

		def correct_user
			@dream = current_user.dreams.find_by(id: params[:id])
			redirect_to root_url if @dream.nil?
		end




end

