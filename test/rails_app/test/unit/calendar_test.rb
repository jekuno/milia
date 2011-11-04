require 'test_helper'

class CalendarTest < ActiveSupport::TestCase
  
  context "a calendar" do
    
    setup do
      @user = Factory( :user )  # establishes current_user & tenant
      @calendar = Factory( :calendar )
    end

# validate multi-tenanting structure
    should have_db_column(:tenant_id)
    should_not allow_mass_assignment_of(:tenant_id)
    should "define the current tenant" do
      assert  Thread.current[:tenant_id]
    end
    should "match the current tenant" do
      assert_equal  @calendar.tenant_id, Thread.current[:tenant_id]
    end

# validate the model
    should have_many( :zines )
    should belong_to( :team )
    
  end   # context calendar
  
end   #   class CalendarTest
