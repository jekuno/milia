# **************************************************************************
# The basis for most of this code is from the work-around found on the devise wiki:
# https://github.com/plataformatec/devise/wiki/How-To:-Override-confirmations-so-users-can-pick-their-own-passwords-as-part-of-confirmation-activation
# with selected areas commented out for usage with milia's invite_member process
# **************************************************************************

module Milia

  class ConfirmationsController < Devise::ConfirmationsController

    skip_before_action :authenticate_tenant!   #, :only => [:show, :new, :create]


  # PUT /resource/confirmation
  def update
    if ::Milia.use_invite_member

puts ">>>>>>>>>>>>> confirmable#update - sccp: #{@confirmable.skip_confirm_change_password}\tvalid: #{ @confirmable.valid?} <<<<<<<<<<<<<<<<"
      with_unconfirmed_confirmable do
  #      if @confirmable.has_no_password?   # milea creates a dummy password when accounts are created
          @confirmable.attempt_set_password(user_params)
          if @confirmable.skip_confirm_change_password || @confirmable.valid?
            do_confirm   # user has a password; use it to sign in
          else
            do_show   # needs to create a password
            @confirmable.errors.clear #so that we wont render :new
          end
  #       else
  #         self.class.add_error_on(self, :email, :password_allready_set)
  #       end
      end

      unless @confirmable.errors.empty?   # here if errors
        self.resource = @confirmable
        render :new
      end

    else  # process as normal devise handling
      super
    end

    puts "######### EoU: #{@performed_render) ##########"

  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show

    if ::Milia.use_invite_member

puts ">>>>>>>>>>>>> confirmable#show  <<<<<<<<<<<<<<<<"
      with_unconfirmed_confirmable do
          do_show   # always force password input

  #       if @confirmable.has_no_password? 
  #         do_show
  #       else
  #         do_confirm
  #       end

      end  # do

      unless @confirmable.errors.empty?   # here if errors
        self.resource = @confirmable
        render :new
      end

    else  # process as normal devise handling
      super
    end

  end
  
  protected


  def user_params()
    params.require(:user).permit(:password, :password_confirmation, :confirmation_token)
  end

  def with_unconfirmed_confirmable
    original_token = params[:confirmation_token]
    confirmation_token = Devise.token_generator.digest(User, :confirmation_token, original_token)
    @confirmable = User.find_or_initialize_with_error_by(:confirmation_token, confirmation_token)    
    if !@confirmable.new_record?
      @confirmable.only_if_unconfirmed {yield}
    end
  end

  def do_show
    @confirmation_token = params[:confirmation_token]
    @requires_password = true
    self.resource = @confirmable
    render :show
  end

  def do_confirm
    @confirmable.confirm!
    set_flash_message :notice, :confirmed
    sign_in_and_redirect(resource_name, @confirmable)
  end

  end  # class
end # module
