require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "a user" do
    
    setup do
      @user = Factory( :user )
    end

    should have_one( :author )
    should have_many( :posts ).through( :author )
    should_not allow_value("wild blue").for(:email)
    should have_db_column(:tenant_id)
    should_not allow_mass_assignment_of(:tenant_id)
    should "define the current tenant" do
      assert  Thread.current[:tenant_id]
    end
  
  end   # context user

protected


end  # class
