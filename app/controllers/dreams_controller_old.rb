class DreamsController < ApplicationController
	before_filter :authenticate_user!, except: [:show, :index]	# Method provided by Devise
	before_filter :correct_user, only: [:edit, :update, :destroy]

	def index


    # Initialize filterrific with the following params:
    # * `Student` is the ActiveRecord based model class.
    # * `params[:filterrific]` are any params submitted via web request.
    #   If they are blank, filterrific will try params persisted in the session
    #   next. If those are blank, too, filterrific will use the model's default
    #   filter settings.
    # * Options:
    #     * select_options: You can store any options for `<select>` inputs in
    #       the filterrific form here. In this example, the `#options_for_...`
    #       methods return arrays that can be passed as options to `f.select`
    #       These methods are defined in the model.
    #     * persistence_id: optional, defaults to "<controller>#<action>" string
    #       to isolate session persistence of multiple filterrific instances.
    #       Override this to share session persisted filter params between
    #       multiple filterrific instances.
    #     * default_filter_params: optional, to override model defaults
    #     * available_filters: optional, to further restrict which filters are
    #       in this filterrific instance.
    # This method also persists the params in the session and handles resetting
    # the filterrific params.
    # In order for reset_filterrific to work, it's important that you add the
    # `or return` bit after the call to `initialize_filterrific`. Otherwise the
    # redirect will not work.
		@filterrific = initialize_filterrific(
			Dream,
			params[:filterrific],
			select_options: {
				with_emotion_id: Emotion.options_for_select
			},
			default_filter_params: { search: params[:search] },
		) or return 

    # Get an ActiveRecord::Relation for all students that match the filter settings.
    # You can paginate with will_paginate or kaminari.
    # NOTE: filterrific_find returns an ActiveRecord Relation that can be
    # chained with other scopes to further narrow down the scope of the list,
    # e.g., to apply permissions or to hard coded exclude certain types of records.	

		# @dreams = @filterrific.find.page(params[:page])
		@dreams = @filterrific.find



=begin
		if params[:query].present?
			if params[:impression].present?
				@dreams_raw = Dream.text_search(params[:query]).impression(params[:impression]).where(private: false)
			else
				@dreams_raw = Dream.text_search(params[:query]).where(private: false)
				@dreams = @dreams.text_search(params[:query])
			end
		else
			if params[:impression].present?
				@dreams_raw = Dream.regular.impression(params[:impression]).where(private: false)
			else
				@dreams_raw = Dream.regular.where(private: false)
			end
		end		
=end
		


		#@dreams = @dreams.joins(:user).where("private = ? OR users.id = ?", false, current_user)
		@dreams = @dreams.where(private: false).regular
	


		if params[:time] == ('today' || 'week' || 'month' || 'year' || 'all')

			@sorting_array = []

			if params[:time] == 'today'

				@dreams.each do |dream|
					@sorting_array.push([dream, dream.get_upvotes.where(:created_at => 24.hours.ago..Time.now).size - dream.get_downvotes.where(:created_at => 24.hours.ago..Time.now).size])
				end		
				
			elsif params[:time] == 'week'

				@dreams.each do |dream|
					@sorting_array.push([dream, dream.get_upvotes.where(:created_at => 1.week.ago..Time.now).size - dream.get_downvotes.where(:created_at => 1.week.ago..Time.now).size])
				end		

			elsif params[:time] == 'month'

				@dreams.each do |dream|
					@sorting_array.push([dream, dream.get_upvotes.where(:created_at => 1.month.ago..Time.now).size - dream.get_downvotes.where(:created_at => 1.month.ago..Time.now).size])
				end		

			elsif params[:time] == 'year'

				@dreams.each do |dream|
					@sorting_array.push([dream, dream.get_upvotes.where(:created_at => 1.year.ago..Time.now).size - dream.get_downvotes.where(:created_at => 1.year.ago..Time.now).size])
				end		

			elsif params[:time] == 'all'

				@dreams.each do |dream|
					@sorting_array.push([dream, dream.get_upvotes.size - dream.get_downvotes.size])
				end	

			end					
			@sorting_array = @sorting_array.reverse.each_with_index.sort_by { |a, idx| [a[1], idx] }.reverse.map(&:first).map { |x| x[0] }
			@dreams = @sorting_array

		elsif params[:time] == 'submitted'
			@dreams = @dreams
		elsif params[:time] == 'dreamed'
			@dreams = @dreams.chronological
		else
			@sorting_array = []
			@dreams.each do |dream|
				@sorting_array.push([dream, dream.get_upvotes.where(:created_at => 1.week.ago..Time.now).size - dream.get_downvotes.where(:created_at => 1.week.ago..Time.now).size])
			end
			@sorting_array = @sorting_array.reverse.each_with_index.sort_by { |a, idx| [a[1], idx] }.reverse.map(&:first).map { |x| x[0] }
			@dreams = @sorting_array						
		end

		@dreams_raw = @dreams  # try to get graph to update with filterrific
		@dreams = @dreams.paginate(page: params[:page],per_page: 40)



		@hashes = Hash.new
		@screennames = Hash.new

		@dreams.each do |dream|
			dream.screennames.each do |screenname|
				if @screennames[screenname.id].nil?
					@screennames[screenname.id] = 1
				else
					@screennames[screenname.id] += 1
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

		@hashes = @hashes.sort_by { |k, v| v }
		@hashes.reverse!

	# Graph logic

		@word_count = Hash.new
		# Create hash of word frequencies in all relevant dreams
		@dreams.each do |dream|
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

		respond_to do |format|
			format.html
			format.js
		end

	  # Recover from invalid param sets, e.g., when a filter refers to the
	  # database id of a record that doesn’t exist any more.
	  # In this case we reset filterrific and discard all filter params.
		rescue ActiveRecord::RecordNotFound => e
			# There is an issue with the persisted param_set. Reset it.
			puts "Had to reset filterrific params: #{ e.message }"
			redirect_to(reset_filterrific_url(format: :html)) and return
		

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

		@links = Array.new		
		@nodes = Array.new
		@min_words = [@word_count.length, @min_words_constant].min
		@min_words.times do |n|
			@nodes.push(@word_count.keys[n])

			if n == 1
				@links.push([0,n])
			elsif n > 1
				@links.push([n,0],[n,1])
			end

		end



		@node_text = "["
		@nodes.each do |word|

			@node_text += "{\"name\":\"#{@word_count[word][0]}\",\"value\":#{@word_count[word][1]}},"
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