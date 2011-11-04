require 'test_helper'

class TeamTest < ActiveSupport::TestCase

  context "a team" do
    
    setup do
      @user = Factory( :user )  # establishes current_user & tenant
      @team = Factory( :team )
    end

    should have_db_column(:tenant_id)
    should_not allow_mass_assignment_of(:tenant_id)
    should "define the current tenant" do
      assert  Thread.current[:tenant_id]
    end
    should "match the current tenant" do
      assert_equal  @team.tenant_id, Thread.current[:tenant_id]
    end

    should have_many( :team_assets )
    should have_many( :team_members ).through( :team_assets )
    
    should 'ensure team asset creation' do
      assert  @team.team_assets.size > 1
    end
  
  end   # context team

end # team
