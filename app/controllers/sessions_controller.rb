class SessionsController < Devise::SessionsController
  def create
    #Always remember user
    params[:user].merge!(remember_me: 1)
    # For oauth
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_in_and_redirect(resource_name, resource)

  end
 
  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    flash[:success] = "Logged in"
#    redirect_to after_sign_in_path_for(resource)
    respond_to do |format|
      format.html { redirect_to after_sign_in_path_for(resource) }
      format.json { render :json => {:success => true, :current_user_id => current_user.id}}
    end

   # return render :json => {:success => true, :current_user_id => current_user.id}
  end
 
  def failure
    respond_to do |format|
      format.html do
        flash[:error] = "wrong password"
        redirect_to root_path
      end
      format.json { return render :json => {:success => false, :errors => ["Login failed."]} }
     # return render json: @user.errors.full_messages, status: :unprocessable_entity
    end
  end
end

