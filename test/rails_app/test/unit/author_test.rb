require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  
  context "an author" do
    
    setup do
      @user = Factory( :user )  # establishes current_user & tenant
      @author = Factory( :author, :user => @user )
    end

# validate multi-tenanting structure
    should have_db_column(:tenant_id)
    should_not allow_mass_assignment_of(:tenant_id)
    should "define the current tenant" do
      assert  Thread.current[:tenant_id]
    end
    should "match the current tenant" do
      assert_equal  @author.tenant_id, Thread.current[:tenant_id]
    end

# validate the model
    should belong_to( :user )
    should have_many( :posts )
    should have_many( :team_assets )
    should have_many( :teams ).through( :team_assets )
    
  end   # context author
  
end #   class author
