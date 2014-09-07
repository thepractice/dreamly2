class UsersController < ApplicationController

	def index
		@users = User.paginate(page: params[:page], per_page: 40).order('dream_count DESC')
	end

	def show
		@user = User.find(params[:id])
#		@dreams = @user.dreams.regular.paginate(page: params[:page])

		if params[:query].present?
			if params[:impression].present?
				@dreams = Dream.text_search(params[:query]).impression(params[:impression]).where(user: @user).paginate(page: params[:page])
			else
				@dreams = Dream.text_search(params[:query]).where(user: @user).paginate(page: params[:page])
			end
		else
			if params[:impression].present?
				@dreams = @user.dreams.regular.impression(params[:impression]).paginate(page: params[:page])
			else
				@dreams = @user.dreams.regular.paginate(page: params[:page])
			end
		end

#		if params[:impression].present?
#			@dreams = @user.dreams.regular.impression(params[:impression]).paginate(page: params[:page])
#		elsif params[:query].present?
#			@dreams = Dream.text_search(params[:query]).paginate(page: params[:page]).where(user: @user)
	#		@dreams = Dream.text_search(params[:query]).page(params[:page])
#		end


		# Word association logic
#		@first_word_id = @user.word_freq.keys[0]
#		@first_word = Word.find(@first_word_id)	# Find most frequent Word
#		@first_word_dreams = Array.new
#		@first_word_assocs = Hash.new(0)
		# Set array with dream_ids of @user which contain @first_word
#		@first_word.dreams.each do |dream_id|
#			if Dream.find(dream_id).user_id == @user.id
#				@first_word_dreams.push(dream_id)
#			end
#		end

#		@first_word_dreams.each do |dream_id|														# Iterate through each dream
#			Dream.find(dream_id).word_freq.each do |word_id, frequency|		# Iterate through each unique word
#				if word_id != @first_word_id
#					@first_word_assocs[word_id] += frequency										# Add word count to @first_word_assocs hash
#				end
#			end
#		end

#		@first_word_assocs = Hash[@first_word_assocs.sort_by{ |k, v| v }.reverse]

#		@first_word_first_assoc_id = @first_word_assocs.keys[0]
#		@first_word_first_assoc = Word.find(@first_word_first_assoc_id)

	end

	def graph
		@user = User.find(params[:id])
	end

end