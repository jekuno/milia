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
# current_tenant -- returns tenant obj for current tenant
# ------------------------------------------------------------------------
  def current_tenant()
    return Tenant.find( Thread.current[:tenant_id] )
  end
    
# ------------------------------------------------------------------------
# current_tenant_id -- returns tenant_id for current tenant
# ------------------------------------------------------------------------
  def current_tenant_id()
    return Thread.current[:tenant_id]
  end
  
# ------------------------------------------------------------------------
# set_current_tenant -- model-level ability to set the current tenant
# NOTE: *USE WITH CAUTION* normally this should *NEVER* be done from
# the models ... it's only useful and safe WHEN performed at the start
# of a background job (DelayedJob#perform)
# ------------------------------------------------------------------------
  def set_current_tenant( tenant )
      # able to handle tenant obj or tenant_id
    case tenant
      when Tenant then tenant_id = tenant.id
      when Integer then tenant_id = tenant
      else
        raise ArgumentError, "invalid tenant object or id"
    end  # case
    
    Thread.current[:tenant_id] = tenant_id
  end
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
 
# ------------------------------------------------------------------------
# where_restrict_tenant -- gens tenant restrictive where clause for each klass
# NOTE: subordinate join tables will not get the default scope by Rails
# theoretically, the default scope on the master table alone should be sufficient
# in restricting answers to the current_tenant alone .. HOWEVER, it doesn't feel
# right. adding an additional .where( where_restrict_tenants(klass1, klass2,...))
# for each of the subordinate models in the join seems like a nice safety issue.
# ------------------------------------------------------------------------
  def where_restrict_tenant(*args)
    args.map{|klass| "#{klass.table_name}.tenant_id = #{Thread.current[:tenant_id]}"}.join(" AND ")
  end
  
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

    end  # module ClassMethods
# #############################################################################
# #############################################################################
    
  end  # module Base
end  # module Milia
