require 'test_helper'

class PostTest < ActiveSupport::TestCase
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
  context "a post" do
    
    setup do
      @user = Factory( :user )  # establishes current_user & tenant
      @post = Factory( :post )
    end

# validate multi-tenanting structure
    should have_db_column(:tenant_id)
    should_not allow_mass_assignment_of(:tenant_id)
    should "define the current tenant" do
      assert  Thread.current[:tenant_id]
    end
    should "match the current tenant" do
      assert_equal  @post.tenant_id, Thread.current[:tenant_id]
    end

# validate the model
    should belong_to( :author )
    should belong_to( :zine )

# model-specific tests

  end   # context post
#   
   # test "should get all posts within mangoland" do
     # set_tenant( tenants(:mangoland) )
     # assert_equal 6, Post.count
   # end
#   
   # test "should get only nigel posts in mangoland" do
     # set_tenant( tenants(:mangoland) )
     # assert_equal 1, authors(:nigel_mangoland).posts.size
   # end
# 
  # test "should not get any jermaine posts in mangoland" do
     # set_tenant( tenants(:mangoland) )
     # assert   users(:jermaine).posts.size.zero?
  # end

# _____________________________________________________________________________    

end  # class test
