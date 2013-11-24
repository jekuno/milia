module Milia

  class PasswordsController < Devise::PasswordsController

    skip_before_action :authenticate_tenant!, :only => [:new, :create ]

  end  # class
end # module
