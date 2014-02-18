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

# model-specific tests
   should "get all posts within mangoland" do
     assert_equal (@max_users * @max_teams) + 1, Post.count
   end
  
   should "get only member posts in mangoland" do
     x = Member.all.detect{|a| !a.user.nil? }  # pick an member
     assert x
     assert_equal 1, x.posts.size
   end

    should "not get any non-world user posts in mangoland" do
       x = User.all.last  # should be from islesmile
       assert   x.posts.size.zero?
    end
  
    should "see jemell in two tenants with dif posts" do
       assert_equal   1, @target.posts.size
       assert         %w(wild_blue passion_pink mellow_yellow).include?( @target.posts.first.content.sub(/_\d+/,"") )

       assert_equal   2, @target.posts.size
       assert         @target.posts.all?{ |p| 
          %w(wild_blue passion_pink mellow_yellow).include?( p.content.sub(/_\d+/,"") )
       }
    end

    should "zoom get all team posts" do
      list = Post.get_team_posts( Member.first.teams.first.id ).all
      assert_equal  3,list.size
    end
    
    
  end   # context post

# _____________________________________________________________________________    

end  # class test
