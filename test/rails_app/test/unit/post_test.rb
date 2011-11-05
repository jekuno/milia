require 'test_helper'

class PostTest < ActiveSupport::TestCase
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
  context "a post" do
    
    setup do
      setup_world()
      @post = Factory( :post )  # stock object for validation testing
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
   should "get all posts within mangoland" do
     ActiveSupport::TestCase.set_tenant( @mangoland )
     assert_equal (@max_users * @max_teams) + 1, Post.count
   end
  
   should "get only author posts in mangoland" do
     ActiveSupport::TestCase.set_tenant( @mangoland )
     x = Author.all[1]  # pick an author
     assert_equal 1, x.posts.size
   end

    should "not get any non-world user posts in mangoland" do
       ActiveSupport::TestCase.set_tenant( @mangoland )
       x = User.all.last  # should be from islesmile
       assert   x.posts.size.zero?
    end
  
    should "see jemell in two tenants with dif posts" do
       ActiveSupport::TestCase.set_tenant( @mangoland )
       assert_equal   2, @jemell.posts.size
       ActiveSupport::TestCase.set_tenant( @islesmile )
       assert_equal   1, @jemell.posts.size
    end

    should "zoom get all team posts" do
      ActiveSupport::TestCase.set_tenant( @mangoland )
      list = Post.get_team_posts( Author.first.teams.first.id ).all
      assert_equal  3,list.size
    end
    
  end   # context post

# _____________________________________________________________________________    

end  # class test
