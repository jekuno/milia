require 'test_helper'

class PostTest < ActiveSupport::TestCase
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
  context "a post" do
    
    setup do
      Tenant.set_current_tenant( tenants( :tenant_1 ).id )
      @zine = Zine.first
    end

# validate multi-tenanting structure
    should have_db_column(:tenant_id)
    should "match the current tenant" do
      assert_equal  @zine.tenant_id, Thread.current[:tenant_id]
    end

# validate the model
    should belong_to( :member )
    should belong_to( :zine )
    should have_one(:team).through(:zine)

# model-specific tests
   should "get all posts within tenant" do
     assert_equal 7, Post.count
   end
  
   should "get only member posts in tenant" do
     Tenant.set_current_tenant( tenants( :tenant_2 ).id )

     x = members(:quentin_2)
     assert_equal 2, x.posts.size
   end
  
    should "see jermaine in two tenants with dif posts" do
      jermaine = users( :jermaine )
     Tenant.set_current_tenant( tenants( :tenant_2 ).id )
       assert_equal   1, jermaine.member.posts.size

     Tenant.set_current_tenant( tenants( :tenant_3 ).id )
       jermaine.reload
       assert_equal   6, jermaine.member.posts.size
    end

    should "get all team posts" do
     Tenant.set_current_tenant( tenants( :tenant_2 ).id )
     team = teams( :team_2_b )
     assert_equal  2, team.posts.size
    end

    should 'match team in a post' do
     Tenant.set_current_tenant( tenants( :tenant_2 ).id )
      assert_equal  posts(:post_plum_2_1_b).team, teams(:team_2_b)
    end  # should do
    
    should 'match a posts zine with tenant' do
      Tenant.set_current_tenant( tenants( :tenant_2 ).id )
      assert_equal  2,posts(:post_plum_2_1_b).zine.tenant_id
    end  # should do
    
  end   # context post

# _____________________________________________________________________________    

end  # class test
