class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :configure_mailer
  before_filter :authenticate_user!
  before_filter :set_current_tenant   # forces milia to set up current tenant

protected

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def configure_mailer
    ActionMailer::Base.default_url_options[:host] = request.host
    ActionMailer::Base.default_url_options[:port] = request.port unless request.port == 80
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
# ------------------------------------------------------------------------------
  def prep_signup_view(tenant=nil, user=nil)
    @user   = klass_option_obj( User, user )
    @tenant = klass_option_obj( Tenant, tenant )
    @eula   = Eula.get_latest.first
  end

# ------------------------------------------------------------------------------
#


end
