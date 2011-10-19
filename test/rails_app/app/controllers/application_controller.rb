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




end
