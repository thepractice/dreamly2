class MessagesController < ApplicationController
	before_action :authenticate_user!

	def new
	end

	def create
		recipients = User.where(id: params['recipients'])
		user2 = recipients.first
		conv_check_1 = Mailboxer::Conversation.participant(user2)
		conv_check_2 = Mailboxer::Conversation.participant(current_user)
		@dialog = (conv_check_1 & conv_check_2).first
		if @dialog.nil? or !@dialog.is_participant?(current_user)
			conversation = current_user.send_message(user2, params[:message][:body], params[:message][:subject]).conversation
			flash[:success] = "Message has been sent!"
			redirect_to conversation_path(conversation)
		else
			current_user.reply_to_conversation(@dialog, params[:message][:body])
			flash[:success] = "Message has been sent!"
			redirect_to conversation_path(@dialog)
		end
		user2.notify('Message', 'You received a message')
		
	end

end

