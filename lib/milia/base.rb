module Milia
  module Base

    def self.included(base)
      base.extend ClassMethods
    end

# #############################################################################
# #############################################################################
    module ClassMethods

# ------------------------------------------------------------------------
# acts_as_tenant -- makes a tenanted model
# Forces all references to be limited to current_tenant rows
# ------------------------------------------------------------------------
      def acts_as_tenant()
        attr_protected :tenant_id
        default_scope lambda { where( "#{table_name}.tenant_id = ?", Thread.current[:tenant_id] ) }
        before_save do |obj|   # force tenant_id to be correct for current_user
          obj.tenant_id = Thread.current[:tenant_id]
          true  ok to proceed
        end
      end

# ------------------------------------------------------------------------
# acts_as_universal -- makes a univeral (non-tenanted) model
# Forces all reference to the universal tenant (nil)
# ------------------------------------------------------------------------
      def acts_as_universal()
        attr_protected :tenant_id
        default_scope where( "#{table_name}.tenant_id IS NULL" )
        before_save do |obj|   # force tenant_id to be correct for current_user
          obj.tenant_id = nil
          true  ok to proceed
        end
      end
      
# ------------------------------------------------------------------------
# acts_as_universal_and_determines_tenant_reference
# All the characteristics of acts_as_universal AND also does the magic
# of binding a user to a tenant
# ------------------------------------------------------------------------
      def acts_as_universal_and_determines_tenant_reference()
        acts_as_universal()
        
          # before create, tie user with current tenant
          # return true if ok to proceed; false if break callback chain
        before_create do |new_user|
          tenant = Tenant.find( Thread.current[:tenant_id] )
          return true if tenant.my_users.include?(new_user)

          tenant.my_users << new_user  # add user to this tenant if not already there
          new_user.my_tenants << tenant   # add to tenants ok list
          return tenant.save!   # false if error breaks callback chain

        end # before_create do
        
      end  # acts_as

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

    end  # module ClassMethods
# #############################################################################
# #############################################################################
    
  end  # module Base
end  # module Milia