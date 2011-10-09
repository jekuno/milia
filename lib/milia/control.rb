module Milia
  module Control
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      
    end  # module ClassMethods
    
    def set_tenant()
      @@_my_tenants = current_user.my_tenants
      @@_current_tenant = @@_my_tenants.first.my_tenants
    end
    
  end  # module Control
end  # module Milia