module Milia

  class SessionsController < Devise::SessionsController

    skip_before_action :authenticate_tenant!, :only => [:new, :create]

  end  # class
end # module
