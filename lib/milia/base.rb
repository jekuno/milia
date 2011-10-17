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
        belongs_to  :tenant
        validates_presence_of :tenant_id

        default_scope lambda { where( "#{table_name}.tenant_id = ?", Thread.current[:tenant_id] ) }

      # ..........................callback enforcers............................
        before_save do |obj|   # force tenant_id to be correct for current_user
          obj.tenant_id = Thread.current[:tenant_id]
          true  #  ok to proceed
        end

      # ..........................callback enforcers............................
        before_update do |obj|   # force tenant_id to be correct for current_user
          raise ::Control::InvalidTenantAccess unless obj.tenant_id == Thread.current[:tenant_id]
          true  #  ok to proceed
        end

      # ..........................callback enforcers............................
        before_destroy do |obj|   # force tenant_id to be correct for current_user
          raise ::Control::InvalidTenantAccess unless obj.tenant_id == Thread.current[:tenant_id]
          true  #  ok to proceed
        end

      end

# ------------------------------------------------------------------------
# acts_as_universal -- makes a univeral (non-tenanted) model
# Forces all reference to the universal tenant (nil)
# ------------------------------------------------------------------------
      def acts_as_universal()
        attr_protected :tenant_id
        belongs_to  :tenant

        default_scope where( "#{table_name}.tenant_id IS NULL" )

      # ..........................callback enforcers............................
        before_save do |obj|   # force tenant_id to be universal
          raise ::Control::InvalidTenantAccess unless obj.tenant_id.nil?
          true  #  ok to proceed
        end

      # ..........................callback enforcers............................
        before_update do |obj|   # force tenant_id to be universal
          raise ::Control::InvalidTenantAccess unless obj.tenant_id.nil?
          true  #  ok to proceed
        end

      # ..........................callback enforcers............................
        before_destroy do |obj|   # force tenant_id to be universal
          raise ::Control::InvalidTenantAccess unless obj.tenant_id.nil?
          true  #  ok to proceed
        end

      end
      
# ------------------------------------------------------------------------
# acts_as_universal_and_determines_tenant_reference
# All the characteristics of acts_as_universal AND also does the magic
# of binding a user to a tenant
# ------------------------------------------------------------------------
      def acts_as_universal_and_determines_account()
        has_and_belongs_to_many :tenants

        acts_as_universal()
        
          # before create, tie user with current tenant
          # return true if ok to proceed; false if break callback chain
        after_create do |new_user|
          tenant = Tenant.find( Thread.current[:tenant_id] )
          unless tenant.users.include?(new_user)
            tenant.users << new_user  # add user to this tenant if not already there
          end

        end # before_create do
        
        before_destroy do |old_user|
          old_user.tenants.clear    # remove all tenants for this user
          true
        end # before_destroy do
        
      end  # acts_as

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
  def acts_as_universal_and_determines_tenant()
        has_and_belongs_to_many :users

        acts_as_universal()
        
        before_destroy do |old_tenant|
          old_tenant.users.clear  # remove all users from this tenant
          true
        end # before_destroy do
        
  end
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

    end  # module ClassMethods
# #############################################################################
# #############################################################################
    
  end  # module Base
end  # module Milia