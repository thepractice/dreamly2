class DreamsController < ApplicationController
	before_filter :authenticate_user!, except: [:show, :index]	# Method provided by Devise
	before_filter :correct_user, only: [:edit, :update, :destroy]

	def index
	end

	def show
		@dream = Dream.find(params[:id])
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
		if @dream.update_attributes(dream_params)
			flash[:success] = "Changes saved"
			redirect_to @dream
		else
			render 'edit'
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