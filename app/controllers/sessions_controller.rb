module Milia

  class SessionsController < Devise::SessionsController

    skip_before_action :authenticate_tenant!, :only => [:new, :create, :destroy]

    def destroy
      __milia_reset_tenant!   # clear tenanting
      super
    end

  end  # class
end # module
