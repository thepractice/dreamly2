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

		@sorting_array = []

		if params[:time] == '24hr'

			@dreams_raw.each do |dream|
				@sorting_array.push([dream, dream.get_upvotes.where(:created_at => 24.hours.ago..Time.now).size - dream.get_downvotes.where(:created_at => 24.hours.ago..Time.now).size])
			end		
			
		elsif params[:time] == 'week'

			@dreams_raw.each do |dream|
				@sorting_array.push([dream, dream.get_upvotes.where(:created_at => 1.week.ago..Time.now).size - dream.get_downvotes.where(:created_at => 1.week.ago..Time.now).size])
			end		

		elsif params[:time] == 'month'

			@dreams_raw.each do |dream|
				@sorting_array.push([dream, dream.get_upvotes.where(:created_at => 1.month.ago..Time.now).size - dream.get_downvotes.where(:created_at => 1.month.ago..Time.now).size])
			end		

		elsif params[:time] == 'year'

			@dreams_raw.each do |dream|
				@sorting_array.push([dream, dream.get_upvotes.where(:created_at => 1.year.ago..Time.now).size - dream.get_downvotes.where(:created_at => 1.year.ago..Time.now).size])
			end		

		elsif params[:time] == 'all'

			@dreams_raw.each do |dream|
				@sorting_array.push([dream, dream.get_upvotes.size - dream.get_downvotes.size])
			end							

		else

			@dreams_raw.each do |dream|
				@sorting_array.push([dream, dream.get_upvotes.where(:created_at => 1.week.ago..Time.now).size - dream.get_downvotes.where(:created_at => 1.week.ago..Time.now).size])
			end		

		end

		@dreams_raw = @sorting_array.reverse.each_with_index.sort_by { |a, idx| [a[1], idx] }.reverse.map(&:first).map { |x| x[0] }




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
		@dreams_raw.each do |dream|
			dream.word_freq.each do |stem, info_array|
				if @word_count[info_array[0]] == nil
					@word_count[info_array[0]] = { freq: info_array[1], dream_ids: [dream.id] }
				else
					@word_count[info_array[0]][:freq] += info_array[1]
					@word_count[info_array[0]][:dream_ids].push(dream.id)
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

	#	end    # What does this end?	

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

	def upvote
		@dream = Dream.find(params[:id])
		if user_signed_in?
			if current_user.voted_as_when_voted_for @dream
				@dream.unliked_by current_user
			else
				@dream.liked_by current_user
		end

		

		@dream.liked_by current_user
		session[:return_to] ||= request.referer		#Store the requesting url in the session hash
		respond_to do |format|
			format.html { redirect_to session.delete(:return_to) }	#redirect to the requesting url
			format.js
		end		
	end

	def downvote
		@dream = Dream.find(params[:id])
		@dream.downvote_from current_user
		session[:return_to] ||= request.referer		#Store the requesting url in the session hash
		respond_to do |format|
			format.html { redirect_to session.delete(:return_to) }	#redirect to the requesting url
			format.js
		end
	end	

	def destroy
		@dream.destroy
		redirect_to root_url
	end

	end #?

	private

		def dream_params
			params.require(:dream).permit(:title, :body, :dreamed_on, :impression, :private)
		end

		def correct_user
			@dream = current_user.dreams.find_by(id: params[:id])
			redirect_to root_url if @dream.nil?
		end
		


end