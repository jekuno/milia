module Milia
  module Base
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def acts_as_tenant()
        default_scope lambda { where( 'tenant_id = ?', Thread.current[:tenant_id] ) }
      end

      def acts_as_universal()
        default_scope where( 'tenant_id IS NULL' )
      end

    end  # module ClassMethods
    
  end  # module Base
end  # module Milia