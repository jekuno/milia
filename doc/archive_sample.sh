
# tweaking the web-app-theme to correct for defaults
rails g web_app_theme:assets

# EDIT: app/views/layouts/application.html.haml  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# correct: 
= stylesheet_link_tag 'application'
= javascript_include_tag 'application'

# move images for buttons to correct folder
cp $(bundle show web-app-theme)/spec/dummy/public/images/* app/assets/images/web-app-theme/ -r




# EDIT: app/assets/stylesheets/web-app-theme/basic.css
# correct around line 300, comment out the three lines below and
# add following instead
/*
.form .fieldWithErrors .error {
  color: red;
}
*/

.form input.text_field, .form textarea.text_area {
  width: 100%;
  border-width: 1px;
  border-style: solid;
}

.flash .message {
    -moz-border-radius: 3px;
    -webkit-border-radius: 3px;
    border-radius: 3px;
    text-align: center;
    margin: 0 auto 15px;
    color: white;
    text-shadow: 0 1px 0 rgba(0, 0, 0, 0.3);
  }
  .flash .message p {
    margin: 8px;
  }
  .flash .error, .flash .error-list, .flash .alert {
    border: 1px solid #993624;
    background: #cc4831 url("images/messages/error.png") no-repeat 10px center;
  }
  .flash .warning {
    border: 1px solid #bb9004;
    background: #f9c006 url("images/messages/warning.png") no-repeat 10px center;
  }
  .flash .notice {
    color: #28485e;
    text-shadow: 0 1px 0 rgba(255, 255, 255, 0.7);
    border: 1px solid #8a9daa;
    background: #b8d1e2 url("images/messages/notice.png") no-repeat 10px center;
  }
  .flash .error-list {
    text-align: left;
  }
  .flash .error-list h2 {
    font-size: 16px;
    text-align: center;
  }
  .flash .error-list ul {
    padding-left: 22px;
    line-height: 18px;
    list-style-type: square;
    margin-bottom: 15px;
  }

#<<<< EDIT <<<<<<<<<<<<<<<<<

DEVISE 3.2.1
===================================
  # POST /resource
  def create
    build_resource(sign_up_params)

    if resource.save
      yield resource if block_given?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

DEVISE 2.1.2
===================================
 # POST /resource
  def create
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

Milia 0.3
===================================
  def devise_create_old
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else  # resource had errors ...
      prep_devise_new_view( @tenant, resource )
    end
  end
# ------------------------------------------------------------------------------
  # prep_devise_new_view -- common code to prep for another go at the signup form
# ------------------------------------------------------------------------------
  def prep_devise_new_view( tenant, resource )
    clean_up_passwords(resource)
    prep_signup_view( tenant, resource, params[:coupon] )   # PUNDA special addition
    respond_with_navigational(resource) { render :new }
  end
 
