class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	
	def all
		# To see request hash, use 'render :text => "<pre>#{request.env["omniauth.auth"].to_yaml}</pre>"''
		user = User.from_omniauth(request.env["omniauth.auth"])
		if user.persisted?
			flash[:success] = "Signed in!"
			sign_in_and_redirect user
		else
			# Use session to persist user attributes when validation fails, in order to show error messages.
			# Starting session name with 'devise.' makes devise automatically clean up session.
			session["devise.user_attributes"] = user.attributes 	
			redirect_to new_user_registration_url
		end
	end

	alias_method :twitter, :all 		# Use the :all method when trying to use :twitter method
end
