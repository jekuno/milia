require 'test_helper'

class ZineTest < ActiveSupport::TestCase
  
  context "a zine" do
    
    setup do
      setup_world()
      @zine = Factory( :zine )  # stock object for validation testing
    end

# validate multi-tenanting structure
    should have_db_column(:tenant_id)
    should_not allow_mass_assignment_of(:tenant_id)
    should "define the current tenant" do
      assert  Thread.current[:tenant_id]
    end
    should "match the current tenant" do
      assert_equal  @zine.tenant_id, Thread.current[:tenant_id]
    end

# validate the model
    should have_many( :posts )
    should belong_to( :calendar )
    
  end   # context zine
  
end # class ZineTest 
