module Milia

  class ConfirmationsController < Devise::ConfirmationsController
    prepend_before_filter :require_no_authentication, :only => [ :new, :create, :show ]

    skip_before_action :authenticate_tenant!   #, :only => [:show, :new, :create]

  end  # class
end # module
