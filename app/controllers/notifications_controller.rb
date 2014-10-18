class NotificationsController < ApplicationController

	before_filter :authenticate_user!

	def index
		@notifications = current_user.notifications.regular
		@notifications.each do |notification|
			notification.update_attribute(:seen, true)
		end
	end

end


		# Mark as 'seen' all notifications on dream
	#	if user_signed_in?
	#		@dream.notifications.where(user: current_user, seen: false).each do |notification|
	#		notification.update_attribute(:seen, true)
	#		end
	#	end