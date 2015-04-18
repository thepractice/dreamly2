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
      format.html do
        if params[:forum] == "true"
          redirect_to "http://forum.dreamly.io/session/sso?return_path=%2F"
        else
          redirect_to after_sign_in_path_for(resource)
        end
      end
      format.json { render :json => {:success => true, :current_user_id => current_user.id}}
    end

   # return render :json => {:success => true, :current_user_id => current_user.id}

  end

  # Override devise sign_out method to sign out of Discourse
  def sign_out(resource_or_scope=nil)
    # Get Discourse User ID 
    url = URI.parse("http://forum.dreamly.io/users/by-external/#{current_user.id}.json")
    request = Net::HTTP::Get.new(url)
    resource = Net::HTTP.start(url.host, url.port) do |http|
      http.request(request)
    end
    data = ActiveSupport::JSON.decode(resource.body)
    unless data["user"].nil?
      discourse_id = data["user"]["id"]
      # Post to Discourse API to logout
      uri = URI.parse("http://forum.dreamly.io/admin/users/#{discourse_id}/log_out")
      http = Net::HTTP.new(uri.host, uri.port)
      form_data = {
        "api_key" => "13abd32a53efe06d789c5ef513459ef54ab10231523c871afbc3a90866fafff6",
        "api_username" => "thepractice11"
      }
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(form_data)
      response = http.request(request)
    end

    return sign_out_all_scopes unless resource_or_scope
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    user = warden.user(scope: scope, run_callbacks: false) # If there is no user

    warden.raw_session.inspect # Without this inspect here. The session does not clear.
    warden.logout(scope)
    warden.clear_strategies_cache!(scope: scope)
    instance_variable_set(:"@current_#{scope}", nil)

    !!user
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