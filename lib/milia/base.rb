module Milia
  module Base
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Add a job to the queue
    end  # module ClassMethods
    
  end  # module Base
end  # module Milia