module Milia

  class RegistrationsController < Devise::RegistrationsController

  skip_before_action :authenticate_tenant!, :only => [:new, :create, :cancel]

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# TODO: options if non-standard path for new signups view
# ------------------------------------------------------------------------------
# create -- intercept the POST create action upon new sign-up
# new tenant account is vetted, then created, then proceed with devise create user
# CALLBACK: Tenant.create_new_tenant  -- prior to completing user account
# CALLBACK: Tenant.tenant_signup      -- after completing user account
# ------------------------------------------------------------------------------
def create
  
  sign_out_session!

     # validate recaptcha first unless not enabled
  if !::Milia.use_recaptcha  ||  verify_recaptcha

    Tenant.transaction  do 
      @tenant = Tenant.create_new_tenant(sign_up_params_tenant, sign_up_params_coupon)
      if @tenant.errors.empty?   # tenant created
        
        initiate_tenant( @tenant )    # first time stuff for new tenant

        devise_create   # devise resource(user) creation; sets resource

        if resource.errors.empty?   #  SUCCESS!

            # if we're using milia's invite_member helpers
          if ::Milia.use_invite_member
              # then flag for our confirmable that we won't need to set up a password
            resource.update_attributes( skip_confirm_change_password: true )
          end
        
            # do any needed tenant initial setup
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
    flash[:error] = "Recaptcha codes didn't match; please try again"
    prep_signup_view( sign_up_params_tenant, sign_up_params, sign_up_params_coupon )
    render :new
  end

end   # def create

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

  protected
 
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def sign_up_params_tenant()
    params.require(:tenant).permit(:name)
  end

# ------------------------------------------------------------------------------
# sign_up_params_coupon -- permit coupon parameter if used; else params
# ------------------------------------------------------------------------------
  def sign_up_params_coupon()
    ( ::Milia.use_coupon ? 
      params.require(:coupon).permit(:coupon)  :
      params
    )
  end

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
      prep_signup_view(  @tenant, resource, params[:coupon] )   # PUNDA special addition
      respond_with resource
    end
  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def after_sign_up_path_for(resource)
    root_path
  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def after_inactive_sign_up_path_for(resource)
    root_path
  end
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
 
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

  end   # class Registrations

end  # module Milia
