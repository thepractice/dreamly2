class CommentsController < ApplicationController
	def create
		@dream = Dream.find(params[:dream_id])
		@comment = @dream.comments.build(comment_params)
		@comment.user_id = current_user.id
		respond_to do |format|
			if @comment.save
				flash[:success] = "Comment saved"
				format.html { redirect_to dream_path(@dream) }
				format.json { render json: @dream, location: @dream }
			else
				format.html { render 'edit' }
				format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
			end
		end
		#@comment.save!
		#redirect_to dream_path(@dream)
	end

	def edit
		@dream = Dream.find(params[:dream_id])
		@comment = @dream.comments.find(params[:id])
	end

	def update
		@dream = Dream.find(params[:dream_id])
		@comment = @dream.comments.find(params[:id])
		respond_to do |format|
			if @comment.update_attributes(comment_params)
				flash[:success] = "Changes saved"
				format.html { redirect_to @dream }
				format.json { render json: @dream, location: @dream }
			else
				format.html { render 'edit' }
				format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
			end
		end
	end


	def destroy
		@dream = Dream.find(params[:dream_id])
		@comment = @dream.comments.find(params[:id])
		@comment.destroy
		redirect_to dream_path(@dream)
	end

	private
		def comment_params
			params.require(:comment).permit(:body, :user_id, :private)
		end
end
