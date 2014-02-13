class Tenant < ActiveRecord::Base
  acts_as_universal_and_determines_tenant

  def self.create_new_tenant(params)
    return Tenant.create()
  end  

end
