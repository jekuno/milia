require 'test_helper'

class ZineTest < ActiveSupport::TestCase
  
  context "a zine" do
    
    setup do
      Tenant.set_current_tenant( tenants( :tenant_2 ).id )
      @zine = Zine.first
    end

# validate multi-tenanting structure
    should have_db_column(:tenant_id)
    should "match the current tenant" do
      assert_equal  @zine.tenant_id, Thread.current[:tenant_id]
    end

# validate the model
    should have_many( :posts )
    should belong_to( :team )
    should have_many( :members ).through( :posts )
    
# validate the particular associations in the model
    should 'find members through posts' do
      assert_equal 2, zines( :zine_2_b ).members.count
    end  #should do

    should 'find posts' do
      assert_equal 3, zines( :zine_2_a ).posts.count
    end  #should do

    should 'match a zine with tenant' do
      assert_equal  2,zines( :zine_2_a ).tenant_id
    end  # should do
  


  end   # context zine
  
end # class ZineTest 
