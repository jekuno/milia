module Milia
  module Control

# #############################################################################
    class InvalidTenantAccess < SecurityError; end
    class MaxTenantExceeded < ArgumentError; end
# #############################################################################

    def self.included(base)
      base.extend ClassMethods
    end

# #############################################################################
# #############################################################################
    module ClassMethods

    end  # module ClassMethods
# #############################################################################
# #############################################################################

  public

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def __milia_change_tenant!( tid )
    old_id = ( Thread.current[:tenant_id].nil? ? '%' : Thread.current[:tenant_id] )
    new_id = ( tid.nil? ? '%' : tid.to_s )
    Thread.current[:tenant_id] = tid
    session[:tenant_id] = tid  # remember it going forward
    logger.debug("MILIA >>>>> [change tenant] new: #{new_id}\told: #{old_id}") unless logger.nil?
  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def __milia_reset_tenant!
    __milia_change_tenant!( nil )
    logger.debug("MILIA >>>>> [reset tenant] ") unless logger.nil?
  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def trace_tenanting( fm_msg )
    if ::Milia.trace_on
      tid = ( session[:tenant_id].nil? ? "%/#{Thread.current[:tenant_id]}" : session[:tenant_id].to_s )
      uid = ( current_user.nil?  ?  "%/#{session[:user_id]}"  : "#{current_user.id}")
      logger.debug(
         "MILIA >>>>> [#{fm_msg}] stid: #{tid}\tuid: #{uid}\tus-in: #{user_signed_in?}"
      ) unless logger.nil?
    end # trace check
  end

# ------------------------------------------------------------------------------
# set_current_tenant -- sets the tenant id for the current invocation (thread)
# args
#   tenant_id -- integer id of the tenant; nil if get from current user
# EXCEPTIONS -- InvalidTenantAccess
# ------------------------------------------------------------------------------
    def set_current_tenant( tenant_id = nil )

      if user_signed_in?

        @_my_tenants ||= current_user.tenants  # gets all possible tenants for user

        tenant_id ||= session[:tenant_id]   # use session tenant_id ?

        if tenant_id.nil?  # no arg; find automatically based on user
          tenant_id = @_my_tenants.first.id  # just pick the first one
        else   # validate the specified tenant_id before setup
          raise InvalidTenantAccess unless @_my_tenants.any?{|tu| tu.id == tenant_id}
        end

      else   # user not signed in yet...
        tenant_id = nil   # an impossible tenant_id
      end

      __milia_change_tenant!( tenant_id )
      trace_tenanting( "set_current_tenant" )

      true    # before filter ok to proceed
    end

# ------------------------------------------------------------------------------
# initiate_tenant -- initiates first-time tenant; establishes thread
# assumes not in a session yet (since here only upon new account sign-up)
# ONLY for brand-new tenants upon User account sign up
# arg
#   tenant -- tenant obj of the new tenant
# ------------------------------------------------------------------------------
  def initiate_tenant( tenant )
      __milia_change_tenant!( tenant.id )
  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# authenticate_tenant! -- authorization & tenant setup
# -- authenticates user
# -- sets current tenant
# ------------------------------------------------------------------------------
  def authenticate_tenant!
    unless current_user.present? || authenticate_user!(force: true)
      email = ( params.nil? || params[:user].nil?  ?  "<email missing>"  : params[:user][:email] )
      flash[:error] = "cannot sign in as #{email}; check email/password"
      logger.info("MILIA >>>>> [failed auth user] ") unless logger.nil?
    end

    trace_tenanting( "authenticate_tenant!" )

    # user_signed_in? == true also means current_user returns valid user
    raise SecurityError,"*** invalid user_signed_in  ***" unless user_signed_in?

    set_current_tenant   # relies on current_user being non-nil

      # successful tenant authentication; do any callback
    if self.respond_to?( :callback_authenticate_tenant, true )
      logger.debug("MILIA >>>>> [auth_tenant callback]")
      self.send( :callback_authenticate_tenant )
    end

    true  # allows before filter chain to continue
  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def max_tenants
    logger.info(
      "MILIA >>>>> [max tenant signups] #{Time.now.to_s(:db)} - User: '#{params[:user].try(:email)}', Tenant: '#{params[:tenant].try(:name)}'"
    ) unless logger.nil?

    flash[:error] = "Sorry: new accounts not permitted at this time"

      # if using Airbrake & airbrake gem
    if ::Milia.use_airbrake
      notify_airbrake( $! )  # have airbrake report this -- requires airbrake gem
    end
    redirect_back
  end

# ------------------------------------------------------------------------------
# invalid_tenant -- using wrong or bad data
# ------------------------------------------------------------------------------
  def invalid_tenant
    flash[:error] = "Wrong tenant access"
    redirect_back
  end

# ------------------------------------------------------------------------------
# redirect_back -- bounce client back to referring page
# ------------------------------------------------------------------------------
  def redirect_back
    super(fallback_location: root_path)
  end

# ------------------------------------------------------------------------------
  # klass_option_obj -- returns a (new?) object of a given klass
  # purpose is to handle the variety of ways to prepare for a view
  # args:
  #   klass -- class of object to be returned
  #   option_obj -- any one of the following
  #       -- nil -- will return klass.new
  #       -- object -- will return the object itself
  #       -- hash   -- will return klass.new( hash ) for parameters
# ------------------------------------------------------------------------------
  def klass_option_obj(klass, option_obj)
    return option_obj if option_obj.instance_of?(klass)
    option_obj ||= {}  # if nil, makes it empty hash
    return klass.send( :new, option_obj )
  end

# ------------------------------------------------------------------------------
  # prep_signup_view -- prepares for the signup view
  # args:
  #   tenant: either existing tenant obj or params for tenant
  #   user:   either existing user obj or params for user
  # My signup form has fields for user's email,
  # organization's name (tenant model), coupon code,
# ------------------------------------------------------------------------------
  def prep_signup_view(tenant=nil, user=nil, coupon={coupon:''})
    @user   = klass_option_obj( User, user )
    @tenant = klass_option_obj( Tenant, tenant )
    @coupon = coupon #  if ::Milia.use_coupon
 end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
      # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)

    if ::Milia.signout_to_root
      root_path        # return to index page
    else
        # or return to sign-in page
     scope = Devise::Mapping.find_scope!(resource_or_scope)
     send(:"new_#{scope}_session_path")
    end

  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def after_sign_in_path_for(resource_or_scope)
    welcome_path
  end


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def after_sign_up_path_for(resource_or_scope)
    root_path
  end


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------


# #############################################################################
# #############################################################################

  end  # module Control
end  # module Milia
