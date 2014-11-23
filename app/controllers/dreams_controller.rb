class DreamsController < ApplicationController
	before_filter :authenticate_user!, except: [:show, :index]	# Method provided by Devise
	before_filter :correct_user, only: [:edit, :update, :destroy]

	def index
		
		if params[:query].present?
			if params[:impression].present?
				@dreams_raw = Dream.text_search(params[:query]).impression(params[:impression]).where(private: false)
			else
				@dreams_raw = Dream.text_search(params[:query]).where(private: false)
			end
		else
			if params[:impression].present?
				@dreams_raw = Dream.regular.impression(params[:impression]).where(private: false)
			else
				@dreams_raw = Dream.regular.where(private: false)
			end
		end
		@dreams = @dreams_raw.paginate(page: params[:page], per_page: 40)
		@hashes = Hash.new
		@dreams_raw.each do |dream|
			dream.hashtags.each do |hashtag|
				@hashes[hashtag.id] =+ 1
			end
		end
		@hashes = @hashes.sort_by { |k, v| v }
		@hashes.reverse!

	# Graph logic

		@word_count = Hash.new
		# Create hash of word frequencies in all relevant dreams
		@dreams.each do |dream|
			dream.word_freq.each do |word, frequency|
				if @word_count[word] == nil
					@word_count[word] = { freq: frequency, dream_ids: [dream.id] }
				else
					@word_count[word][:freq] += frequency
					@word_count[word][:dream_ids].push(dream.id)
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
			@word = @nodes[n]
			@word_object_assocs = Hash.new(0)
			@word_object_dreams = @word_count[@word][:dream_ids]

			@word_object_dreams.each do |dream_id|
				Dream.find(dream_id).word_freq.each do |word2, freq|
					if word2 != @word
						@word_object_assocs[word2] += freq
					end
				end
			end

			@word_object_assocs = Hash[@word_object_assocs.sort_by{|k, v| v}.reverse]
			@min_assocs = [@word_object_assocs.length, @min_assocs_constant].min
			@min_assocs.times do |i|
				if @nodes.include? @word_object_assocs.keys[i]		# if the association is already a node
					@links.push([@nodes.index(@word), @nodes.index(@word_object_assocs.keys[i])])	# write the link
				else @nodes.include? @word_object_assocs.keys[i]		
					@nodes.push(@word_object_assocs.keys[i])
					@links.push([@nodes.index(@word), @nodes.index(@word_object_assocs.keys[i])])
				end
			end
		end


		@node_text = "["
		@nodes.each do |word|

			@node_text += "{\"name\":\"#{word}\",\"value\":#{@word_count[word][:freq]}},"
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

	def show
		@dream = Dream.find(params[:id])

		# Mark as 'seen' all notifications on dream
	#	if user_signed_in?
	#		@dream.notifications.where(user: current_user, seen: false).each do |notification|
	#		notification.update_attribute(:seen, true)
	#		end
	#	end


	# Graph logic

		@word_count = @dream.word_freq



		if params[:graph]
			@min_words_constant = 15
		else
			@min_words_constant = 5
		end				

		@nodes = Array.new
		@min_words = [@word_count.length, @min_words_constant].min
		@min_words.times do |n|
			@nodes.push(@word_count.keys[n])
		end

		@node_text = "["
		@nodes.each do |word|

			@node_text += "{\"name\":\"#{word}\",\"value\":#{@word_count[word]}},"
		end
		@node_text = @node_text[0..-2] unless @nodes.empty?				# remove extra comma

		@node_text += "]"

		@graph_text = "{\"nodes\":#{@node_text}}"

	end

	def new
		@dream = current_user.dreams.build
		respond_to do |format|
			format.html
			format.js
		end
	end

	def create
		@dream = current_user.dreams.build(dream_params)

		# Create notifications
		@users = []
		@dream.user.followers.each do |follower|
			Notification.create(user: follower, dream: @dream, other_user_id: @dream.user.id, subject: 'dream')
		end


		respond_to do |format|
			if @dream.save
				flash[:success] = "Dream saved."
				format.html { redirect_to @dream, notice: "Dream saved." }
				#format.js {}
				format.js { render js: "window.location.href = ('#{help_path}');"}
				format.json { render json: @dream, status: :created, location: @dream }
				#format.json { render json: "window.location.pathname='#{help_path}'"}
				#redirect_to @dream, format: 'json'
			else
				format.html { render 'dreams/new' }
				format.json { render json: @dream.errors.full_messages, status: :unprocessable_entity }
			end
		end

=begin
		if @dream.save
			flash[:success] = "Dream saved."
			redirect_to @dream
		else
			render 'dreams/_new'
		end
=end		
	end

	def edit
		@dream = Dream.find(params[:id])
	end

	def update
		@dream = Dream.find(params[:id])

		respond_to do |format|
			if @dream.update_attributes(dream_params)
				flash[:success] = "Changes saved"
				format.html { redirect_to @dream }
				format.json { render json: @dream, location: @dream }
			else
				format.html { render 'edit' }
				format.json { render json: @dream.errors.full_messages, status: :unprocessable_entity }
			end
		end
	end


	def destroy
		@dream.destroy
		redirect_to root_url
	end

	private

		def dream_params
			params.require(:dream).permit(:title, :body, :dreamed_on, :impression, :private)
		end

		def correct_user
			@dream = current_user.dreams.find_by(id: params[:id])
			redirect_to root_url if @dream.nil?
		end
		
end