require 'test_helper'

class TeamTest < ActiveSupport::TestCase

  context "a team" do
    
    setup do
      @tenant = Factory( :tenant )
      set_tenant( @tenant )
  
      @team = Factory( :team )
    end

    should "match the current tenant" do
      assert_equal  @team.tenant_id, Thread.current[:tenant_id]
    end
#    should have_db_column(:tenant_id)
#    should_not allow_mass_assignment_of(:tenant_id)

#    should have_many( :team_assets )
#    should have_many( :team_members ).through( :team_assets )
  
  end   # context team

end # team
