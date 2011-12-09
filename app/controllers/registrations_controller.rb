module Milia

  class RegistrationsController < Devise::RegistrationsController

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# create -- intercept the POST create action upon new sign-up
# new tenant account is vetted, then created, then proceed with devise create user
# CALLBACK: Tenant.create_new_tenant  -- prior to completing user account
# CALLBACK: Tenant.tenant_signup      -- after completing user account
# ------------------------------------------------------------------------------
    def create
      
      sign_out_session!

      # if verify_recaptcha  # ?? does this need: :model => resource ??

        @tenant = Tenant.create_new_tenant(params)
        if @tenant.errors.empty?   # tenant created
          
          initiate_tenant( @tenant )    # first time stuff for new tenant
          super   # devise resource(user) creation; sets resource

          # w/o background task:  Tenant.tenant_signup(resource, @tenant,params[:coupon])
          
          StartupJob.queue_startup(@tenant, resource, params[:coupon])
        
        else
          @user = User.new(params[:user])
          render :action => 'new'
        end
            
      # else
        # flash[:error] = "Recaptcha code error; please re-enter the code and click submit again"
        # @user = User.new(params[:user])
        # render :action => 'new'
      # end

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
# ------------------------------------------------------------------------------

  end   # class Registrations

end  # module Milia
