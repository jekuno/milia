require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "a user" do
    
    setup do
      Tenant.set_current_tenant( tenants( :tenant_1 ).id )
      @user = users(:quentin)
    end

    should have_one( :member )
    should_not allow_value("wild blue").for(:email)
    
    should have_db_column(:tenant_id)
    should have_db_column(:skip_confirm_change_password).with_options(default: false)

    should have_db_index(:email)
    should have_db_index(:confirmation_token)
    should have_db_index(:reset_password_token)
    
    should "define the current tenant" do
      assert  Thread.current[:tenant_id]
    end

    should 'have password' do
      assert !@user.has_no_password?
    end   # should do

    should 'not have password' do
      assert  User.new(email: "billybob@bob.com").has_no_password?
    end   # should do

    should 'attempt set password' do
      assert users(:jermaine).attempt_set_password(
        password: 'wild_blue',
        password_confirmation: 'wild_blue'
      )
    end   # should do

    should '' do
    end   # should do


  
  end   # context user

protected

    # ok to create user, member
#     @user   = User.new( user_params )
#     if @user.save_and_invite_member() && @user.create_member( member_params )


end  # class
