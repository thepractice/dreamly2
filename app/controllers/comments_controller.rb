class CommentsController < ApplicationController
	def create
		@dream = Dream.find(params[:dream_id])
		@comment = @dream.comments.build(comment_params)
		@comment.user_id = current_user.id
		@comment.save!
		redirect_to dream_path(@dream)
	end

	private
		def comment_params
			params.require(:comment).permit(:body, :user_id)
		end
end
