module Milia

  class ConfirmationsController < Devise::ConfirmationsController

    before_action  :shout_out
    skip_before_action :authenticate_tenant!   #, :only => [:show, :new, :create]

private
  def shout_out
  puts " ############ CONFIRMATIONS DEVISE CTLR ################### "
  return true
  end

  end  # class
end # module
