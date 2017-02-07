# **************************************************************************
# **************************************************************************

module Milia

  class ConfirmationsController < Devise::ConfirmationsController

    skip_before_action :authenticate_tenant!
    before_action      :set_confirmable, :only => [ :update, :show ]


  # PUT /resource/confirmation
  # entered ONLY on invite-members usage to set password at time of confirmation
  def update
    if @confirmable.attempt_set_password(user_params)

      # this section is patterned off of devise 3.2.5 confirmations_controller#show

      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      if resource.errors.empty?
        log_action( "invitee confirmed" )
        set_flash_message(:notice, :confirmed)
          # sign in automatically
        sign_in_tenanted_and_redirect(resource)

      else
        log_action( "invitee confirmation failed" )
        respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
      end

    else
      log_action( "invitee password set failed" )
      prep_do_show()  # prep for the form
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :show }
    end  # if..then..else passwords are valid
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  # entered on new sign-ups and invite-members
  def show
    if @confirmable.new_record?  ||
       !::Milia.use_invite_member ||
       @confirmable.skip_confirm_change_password

      log_action( "devise pass-thru" )
      super  # this will redirect
      if @confirmable.skip_confirm_change_password
        sign_in_tenanted(resource)
      end
    else
      log_action( "password set form" )
      prep_do_show()  # prep for the form
    end
    # else fall thru to show template which is form to set a password
    # upon SUBMIT, processing will continue from update
  end

  protected

  def set_confirmable()
    original_token = params[:confirmation_token]
    confirmation_token = Devise.token_generator.digest(User, :confirmation_token, original_token)
    @confirmable = User.find_or_initialize_with_error_by(:confirmation_token, confirmation_token)
  end

  def user_params()
    params.require(:user).permit(:password, :password_confirmation, :confirmation_token)
  end

  def prep_do_show()
    @confirmation_token = params[:confirmation_token]
    @requires_password = true
    self.resource = @confirmable
  end

  def log_action( action )
    logger.debug(
      "MILIA >>>>> [confirm user] #{action} - #{@confirmable.email}"
    ) unless logger.nil?
  end

  # MILIA: adaptation of Devise method for multitenanting
      # Sign in a user
      def sign_in_tenanted(resource)
        sign_in( resource )
        trace_tenanting( "sign in tenanted" )
        set_current_tenant
      end

      # Sign in a user and tries to redirect
      def sign_in_tenanted_and_redirect(resource)
        sign_in_tenanted(resource)
        redirect_to after_sign_in_path_for(resource)
      end



  end  # class
end # module
