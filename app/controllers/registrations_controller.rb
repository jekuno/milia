module Milia

  class RegistrationsController < Devise::RegistrationsController

  skip_before_filter :authenticate_tenant!

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# TODO: options if using recaptcha
# TODO: options if non-standard path for new signups view
# ------------------------------------------------------------------------------
# create -- intercept the POST create action upon new sign-up
# new tenant account is vetted, then created, then proceed with devise create user
# CALLBACK: Tenant.create_new_tenant  -- prior to completing user account
# CALLBACK: Tenant.tenant_signup      -- after completing user account
# ------------------------------------------------------------------------------
def create
  
  sign_out_session!

  if verify_recaptcha  # ?? does this need: :model => resource ??

    Tenant.transaction  do 
      @tenant = Tenant.create_new_tenant(params)
      if @tenant.errors.empty?   # tenant created
        
        initiate_tenant( @tenant )    # first time stuff for new tenant

        devise_create   # devise resource(user) creation; sets resource

        if resource.errors.empty?
          Tenant.tenant_signup(resource, @tenant, params[:coupon])
        else  # user creation failed; force tenant rollback
          raise ActiveRecord::Rollback   # force the tenant transaction to be rolled back  
        end  # if..then..else for valid user creation

      else
        prep_signup_view( @tenant, params[:user] , params[:coupon])
        render :new
      end # if .. then .. else no tenant errors

    end  #  wrap tenant/user creation in a transaction
        
  else
    flash[:error] = "Recaptcha code error; please re-enter the code and click submit again"
    prep_signup_view( params[:tenant], params[:user], params[:coupon] )
    render :new
  end

end   # def create

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  private
# ------------------------------------------------------------------------------
# sign_out_session! -- force the devise session signout
# ------------------------------------------------------------------------------

    def sign_out_session!()
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name) if user_signed_in?
    end

# ------------------------------------------------------------------------------
# devise_create -- duplicate of Devise::RegistrationsController
    # same as in devise gem EXCEPT need to prep signup form variables
# ------------------------------------------------------------------------------
  def devise_create
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => inactive_reason(resource) if is_navigational_format?
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
    respond_with_navigational(resource) { render_with_scope :new }
  end
  
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

  end   # class Registrations

end  # module Milia
