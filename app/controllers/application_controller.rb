class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?


  # Override devise method to get omniauth logins to redirect to user page.
  def after_sign_in_path_for(resource)
    current_user
  end

  # Mailboxer
#  rescue_from ActiveRecord::RecordNotFound do
#    flash[:warning] = 'Resource not found.'
#    redirect_back_or root_path    
#  end

  def redirect_back_or(path)
    redirect_to request.referer || path
  end

  protected

  	def configure_permitted_parameters
  		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :name, :email, :password,
  																														:password_confirmation, :remember_me, :avatar) }
  		devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :name, :email, :password,
  																														:remember_me) }
  		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :name, :email, :password,
  																																	 :password_confirmation, :current_password, :avatar) }
  	end
end
