class DreamsController < ApplicationController
	before_filter :authenticate_user!, except: [:show, :index]	# Method provided by Devise

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

	def edit
		@dream = Dream.find(params[:id])
	end

	def update
		@dream = Dream.find(params[:id])
		if @dream.update_attributes(dream_params)
			flash[:success] = "Changes saved"
			redirect_to @dream
		else
			render 'edit'
		end
	end


	def destroy
	end

	private

		def dream_params
			params.require(:dream).permit(:title, :body)
		end
end