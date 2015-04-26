class RegistrationsController < Devise::RegistrationsController

#  def create
#    build_resource(sign_up_params)

#    resource_saved = resource.save
#    yield resource if block_given?
#    if resource_saved
#      if resource.active_for_authentication?
#        set_flash_message :notice, :signed_up if is_flashing_format?
#        sign_up(resource_name, resource)
#        return render :json => {:success => true, :current_user_id => current_user.id}
#      else
#        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
#        expire_data_after_sign_in!
#        return render :json => {:success => true, :current_user_id => current_user.id}
#      end
#    else
#      clean_up_passwords resource
#      return render :json => {:success => false, :errors => resource.errors.full_messages}
#    end
#  end


  # POST /resource
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        if current_user == nil
          #render :js => "window.location.pathname = '#{root_path}'"
          #return render :json => {
          #  :location => url_for(:controller => 'dreams', :action => 'index'),
          #  :flash => {:notice => 'Confirm via email'}
          #}
          return render :json => {:success => true, :current_user_id => 0}
        else
          return render :json => {:success => true, :current_user_id => current_user.id}
        end
        #respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        if current_user == nil
          #render :js => "window.location.pathname = '#{root_path}'"
          #return render :json => {
          #  :location => url_for(:controller => 'dreams', :action => 'index'),
          #  :flash => {:notice => 'Confirm via email'}
          #}  
          return render :json => {:success => true, :current_user_id => 0}        
        else
          return render :json => {:success => true, :current_user_id => current_user.id}
        end      
        #respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end

    User.find(1).send_message(resource, "Welcome to dreamly!", "New message")


    else
      clean_up_passwords resource
      return render :json => {:success => false, :errors => resource.errors.full_messages}
      #set_minimum_password_length
      #respond_with resource
    end
  end


end
