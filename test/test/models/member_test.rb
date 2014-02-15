require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  
  context "a member" do
    
    setup do
      Tenant.set_current_tenant( tenants( :tenant_1 ).id )
      @member = members(:quentin_1)
    end

# validate multi-tenanting structure
    should have_db_column(:tenant_id)
    should "define the current tenant" do
      assert  Thread.current[:tenant_id]
    end
    should "match the current tenant" do
      assert_equal  @member.tenant_id, Thread.current[:tenant_id]
    end

# validate the model
    should belong_to( :user )
    should have_many( :posts )
    should have_many( :zines ).through( :posts )
    should have_many( :team_assets )
    should have_many( :teams ).through( :team_assets )
    
  end   # context member
  
end #   class member
