module Milia
class ApplicationController < ActionController::Base

  # catch any exceptions with the following

  rescue_from ::Milia::Control::MaxTenantExceeded, :with => :max_tenants
  rescue_from ::Milia::Control::InvalidTenantAccess, :with => :invalid_tenant

# **************************************************************************
protected
# **************************************************************************

# ------------------------------------------------------------------------------
# authenticate_tenant! -- authorization & tenant setup
# -- authenticates user
# -- sets current tenant
# -- sets up app environment for this user
# ------------------------------------------------------------------------------
  def authenticate_tenant!()

    unless authenticate_user!
      email = ( params.nil? || params[:user].nil?  ?  "<email missing>"  : params[:user][:email] )

      flash[:error] = "cannot sign in as #{email}; check email/password"

      return false  # abort the before_filter chain
    end

    # user_signed_in? == true also means current_user returns valid user
    raise SecurityError,"*** invalid sign-in  ***" unless user_signed_in?

    set_current_tenant   # relies on current_user being non-nil

    # any application-specific environment set up goes here
    yield if block_given?

    true  # allows before filter chain to continue
  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def max_tenants()
    logger.info("MARKETING - New account attempted #{Time.now.to_s(:db)} - User: #{params[:user][:email]}, org: #{params[:tenant][:company]}")
    flash[:error] = "Sorry: new accounts not permitted at this time"
      
    # uncomment if using Airbrake & airbrake gem
    #  notify_airbrake( $! )  # have airbrake report this -- requires airbrake gem
    redirect_back
  end
  
# ------------------------------------------------------------------------------
# invalid_tenant -- using wrong or bad data
# ------------------------------------------------------------------------------
  def invalid_tenant
    flash[:error] = "wrong tenant access; sign out & try again"
    redirect_back
  end
 
# ------------------------------------------------------------------------------
# redirect_back -- bounce client back to referring page
# ------------------------------------------------------------------------------
  def redirect_back
    redirect_to :back rescue redirect_to root_path
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
  def prep_signup_view(tenant=nil, user=nil, coupon='')
    @user   = klass_option_obj( User, user )
    @tenant = klass_option_obj( Tenant, tenant )
    @coupon = coupon if ::Milia.use_coupon
 end

# **************************************************************************
private
# **************************************************************************
  
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


# **************************************************************************
end  # class
# **************************************************************************
end  # module
