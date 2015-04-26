class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	
	def all
		# To see request hash, use 'render :text => "<pre>#{request.env["omniauth.auth"].to_yaml}</pre>"''
		#render :text => "<pre>#{request.env["omniauth.auth"].to_yaml}</pre>"
		user = User.from_omniauth(request.env["omniauth.auth"])
		user.skip_confirmation!
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

#  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
 #   @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)

#    if @user.persisted?
#      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
#      sign_in_and_redirect @user, :event => :authentication
#    else
#      session["devise.google_data"] = request.env["omniauth.auth"]
#      redirect_to new_user_registration_url
#    end
#	end

	alias_method :twitter, :all 		# Use the :all method when trying to use :twitter method
	alias_method :facebook, :all
	alias_method :google_oauth2, :all
	alias_method :yahoo, :all

end
