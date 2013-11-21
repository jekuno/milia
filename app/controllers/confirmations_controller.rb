module Milia

  class ConfirmationsController < Devise::ConfirmationsController

    skip_before_action :authenticate_tenant!, :only => [:show]

  end  # class
end # module
