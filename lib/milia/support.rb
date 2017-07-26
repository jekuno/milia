module Milia
  module Support

    # Validate the content and type of the given tenant_id. Currently
    # Integers and Strings (UUID) are supported.
    def self.valid_tenant_id?(tenant_id)
      return false if tenant_id.blank?
      return false if tenant_id.kind_of?(Integer) && tenant_id.zero?
      return false if !(tenant_id.kind_of?(Integer) || tenant_id.kind_of?(String))
      true
    end

  end
end
