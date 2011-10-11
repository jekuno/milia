module Milia

class User
  class RegistrationsController < Devise::RegistrationsController

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
    def create
      
      sign_out_session!

      @tenant = Tenant.create_new_tenant(params)
      if @tenant.errors.empty?   # tenant created
        
        initiate_tenant( @tenant )    # first time stuff for new tenant
        super   # do the rest of the user account creation
      
      else
        @user = User.new(params[:user])
        render :action => 'new'
      end
            
    end   # def create
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

  end   # class Registrations
end   # class User

end  # module Milia