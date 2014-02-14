require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "a user" do
    
    setup do
      Tenant.set_current_tenant( tenants( :tenant_1 ).id )
      @user = users(:quentin)
    end

    should have_one( :member )
    #should have_many( :posts ).through( :member )
    should_not allow_value("wild blue").for(:email)
    should have_db_column(:tenant_id)
    should "define the current tenant" do
      assert  Thread.current[:tenant_id]
    end
  
  end   # context user

protected


end  # class
