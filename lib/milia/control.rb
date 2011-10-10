module Milia
  module Control

# #############################################################################
    class InvalidTenantAccess < SecurityError; end
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
    
  private

# ------------------------------------------------------------------------------
# set_current_tenant -- sets the tenant id for the current invocation (thread)
# args
#   tenant_id -- integer id of the tenant; nil if get from current user
# EXCEPTIONS -- InvalidTenantAccess
# ------------------------------------------------------------------------------
    def set_current_tenant( tenant_id = nil )
      @_my_tenants ||= current_user.my_tenants  # gets all possible tenants for user
      
      if tenant_id.nil?  # no arg; find automatically from user
        tenant_id = @_my_tenants.first.my_tenant_id
      else   # passed an arg; validate tenant_id before setup
        raise InvalidTenantAccess unless @_my_tenants.any?{|tu| tu.my_tenant_id == tenant_id}
      end
      
      Thread.current[:tenant_id] = tenant_id
      
      true    # before filter ok to proceed
    end
    
# #############################################################################
# #############################################################################

  end  # module Control
end  # module Milia