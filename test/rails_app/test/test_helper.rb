ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting

  fixtures :all


protected

  def set_tenant( tenant )
    Thread.current[:tenant_id]  = tenant.id
  end
  
  def reset_tenant()
     Thread.current[:tenant_id]  = 0   # an impossible tenant
  end

end   #  class ActiveSupport::TestCase
