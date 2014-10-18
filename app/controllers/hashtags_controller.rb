class HashtagsController < ApplicationController

	def index
		@hashtags = Hashtag.all
	end

	def show
		@hashtag = Hashtag.friendly.find(params[:id])
		
		@dreams_raw
		@dreams = @dreams_raw.paginate(page: params[:page])
	end

end
