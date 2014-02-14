ENV["RAILS_ENV"] ||= "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase

  ActiveRecord::Migration.check_pending!

# -----------------------------------------------------------------------------
# class-level stuff for handling multitenanting setups
# -----------------------------------------------------------------------------
  class << self
    
    def set_tenant( tenant )
      Thread.current[:tenant_id]  = tenant.id
    end
    
    def current_tenant()
      return Thread.current[:tenant_id]
    end
    
    def reset_tenant()
       Thread.current[:tenant_id]  = nil   # starting point; no tenant
    end
    
    def void_tenant()
       Thread.current[:tenant_id]  = 0   # an impossible tenant
    end
    
  end  #  anon class
  
  # Add more helper methods to be used by all tests here...

end   #  class ActiveSupport::TestCase

