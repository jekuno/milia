require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "a user" do
    
    setup do
      @tenant = Factory( :tenant )
      set_tenant( @tenant )
  
      @user = Factory( :user )
       puts ">>>>> user email is: " + @user.email
    end

    should have_one( :author )
    should have_many( :posts ).through( :author )
    should_not allow_value("wild blue").for(:email)
    should have_db_column(:tenant_id)
    should_not allow_mass_assignment_of(:tenant_id)
    should "define the current tenant" do
      assert_equal  @tenant.id, Thread.current[:tenant_id]
    end

    should "echo conditions" do
       # nil.wildblue
    end
  
  end   # context user

protected


end  # class
