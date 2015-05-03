class CommentsController < ApplicationController
	before_filter :find_type

	def create
		#if params[:commentable_type] == "Dream"
		#	@object = Dream.find(params[:dream_id])
		#elsif params[:commentable_type] == "Article"
		#	@object = Article.find(params[:article_id])
		#end
		#@dream = Dream.find(params[:dream_id])
		@comment = @commentable.comments.build(comment_params)
		@comment.user_id = current_user.id
		respond_to do |format|
			if @comment.save
				flash[:success] = "Comment saved"
				format.html { redirect_to @commentable }
				format.json { render json: @commentable, location: @commentable }
			else
				format.html { render 'edit' }
				format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
			end
		end

		if params[:commentable_type] == "Dream"
		# Create notifications
			@users = [@commentable.user]
			@commentable.comments.each do |comment|
				if comment.user != @comment.user
					@users.push(comment.user)
				end
			end
			@users.uniq!
			@users.each do |user|
				Notification.create(dream: @commentable, user: user, other_user_id: @comment.user.id, subject: 'comment')
			end
		end


	end

	def edit
		#@dream = Dream.find(params[:dream_id])
		@comment = @commentable.comments.find(params[:id])
	end

	def update
		#@dream = Dream.find(params[:dream_id])
		@comment = @commentable.comments.find(params[:id])
		respond_to do |format|
			if @comment.update_attributes(comment_params)
				flash[:success] = "Changes saved"
				format.html { redirect_to @commentable }
				format.json { render json: @commentable, location: @commentable }
			else
				format.html { render 'edit' }
				format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
			end
		end
	end


	def destroy
		#@dream = Dream.find(params[:dream_id])
		@comment = @commentable.comments.find(params[:id])
		@comment.destroy
		redirect_to @commentable
	end

	private
		def comment_params
			params.require(:comment).permit(:body, :user_id, :private)
		end

		def find_type
			#@klass = params[:comment][:commentable_type].capitalize.constantize
			#@object = @klass.find(params[:comment][:commentable_id])

			resource, id = request.path.split('/')[1, 2]
			@commentable = resource.singularize.classify.constantize.find(id)
		end
end
