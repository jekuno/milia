module Milia

  class ConfirmationsController < Devise::ConfirmationsController

    skip_before_action :authenticate_tenant!   #, :only => [:show, :new, :create]

# from: https://github.com/plataformatec/devise/wiki/How-To:-Override-confirmations-so-users-can-pick-their-own-passwords-as-part-of-confirmation-activation

  # PUT /resource/confirmation
  def update
    with_unconfirmed_confirmable do
#      if @confirmable.has_no_password?   # milea creates a dummy password when accounts are created
        @confirmable.attempt_set_password(params[:user])
        if @confirmable.valid?
          do_confirm
        else
          do_show
          @confirmable.errors.clear #so that we wont render :new
        end
#       else
#         self.class.add_error_on(self, :email, :password_allready_set)
#       end
    end

    if !@confirmable.errors.empty?
      render :new
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show

    with_unconfirmed_confirmable do
        do_show   # always force password input & TOS acceptance

#       if @confirmable.has_no_password? 
#         do_show
#       else
#         do_confirm
#       end

    end  # do

    if !@confirmable.errors.empty?
      render :new
    end
  end
  
  protected

  def with_unconfirmed_confirmable
    @confirmable = User.find_or_initialize_with_error_by(:confirmation_token, params[:confirmation_token])
    if !@confirmable.new_record?
      @confirmable.only_if_unconfirmed {yield}
    end
  end

  def do_show
    @confirmation_token = params[:confirmation_token]
    @requires_password = true
    self.resource = @confirmable
    @eula  = Eula.get_latest.first
    render :show
  end

  def do_confirm
    @confirmable.confirm!
    set_flash_message :notice, :confirmed
    sign_in_and_redirect(resource_name, @confirmable)
  end

  end  # class
end # module
