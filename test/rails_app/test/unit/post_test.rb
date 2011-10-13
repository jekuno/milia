require 'test_helper'

class PostTest < ActiveSupport::TestCase
   fixtures  :tenants, :users, :posts
   
   def setup()
     reset_tenant
   end
  
   test "should get all posts within the current tenant" do
     set_tenant( tenants(:mangoland) )
     assert_equal 4, Post.count
   end
  
   test "should get only nigel posts for the current tenant" do
     set_tenant( tenants(:mangoland) )
     assert_equal 1, users(:nigel).posts.size
   end

  test "should not get any jermaine posts in mangoland" do
     set_tenant( tenants(:mangoland) )
     assert   users(:jermaine).posts.size.zero?
  end


end  # class test
