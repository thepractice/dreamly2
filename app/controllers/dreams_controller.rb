class DreamsController < ApplicationController

	def index
	end

	def show
		@dream = Dream.find(params[:id])
	end

	def new
		@dream = current_user.dreams.build
	end

	def create
		@dream = current_user.dreams.build(dream_params)
		if @dream.save
			flash[:success] = "Dream saved."
			redirect_to @dream
		else
			render 'dreams/new'
		end
	end

	def destroy
	end

	private

		def dream_params
			params.require(:dream).permit(:title, :body)
		end
end