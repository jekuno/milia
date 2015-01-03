module Milia

  class SessionsController < Devise::SessionsController
       # skip need for authentication
    skip_before_action :authenticate_tenant!, :only => [:new, :create, :destroy]
       # clear tenanting
    before_action :__milia_reset_tenant!, :only => [:create, :destroy]

#     def create
#       Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
#       super
#     end

#     def destroy
#       super
#     end

  end  # class
end # module
