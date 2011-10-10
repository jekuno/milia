module Milia
  module Base
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def acts_as_tenant()
        attr_protected :tenant_id
        default_scope lambda { where( 'tenant_id = ?', Thread.current[:tenant_id] ) }
        before_save do |obj|   # force tenant_id to be correct for current_user
          obj.tenant_id = Thread.current[:tenant_id]
        end
      end

      def acts_as_universal()
        attr_protected :tenant_id
        default_scope where( 'tenant_id IS NULL' )
        before_save do |obj|   # force tenant_id to be correct for current_user
          obj.tenant_id = nil
        end
      end

    end  # module ClassMethods
    
  end  # module Base
end  # module Milia