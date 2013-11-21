module Milia

  class ConfirmationsController < Devise::ConfirmationsController

    skip_before_action :authenticate_tenant!, :only => [:show, :new, :create]

  end  # class
end # module
