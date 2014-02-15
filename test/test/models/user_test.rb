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

    should 'check or set password - missing' do
      user = User.new(email: "billybob@bob.com")
      assert user.has_no_password?
      user.check_or_set_password
      assert !user.has_no_password?
      assert !user.skip_confirm_change_password?
    end   # should do

    should 'check or set password - present' do
      user = User.new(
        email: "billybob@bob.com",
        password: 'limesublime',
        password_confirmation: 'limesublime'
      )
      assert !user.has_no_password?
      user.check_or_set_password
      assert user.skip_confirm_change_password?
    end   # should do

    should 'save and invite member - error no email' do
      user = User.new(password: "wildblue")
      assert_nil user.save_and_invite_member
      assert !user.errors.empty?
    end   # should do

    should 'save and invite member - error duplicate email' do
      user = User.new(email: "jermaine@example.com")
      assert_nil user.save_and_invite_member
      assert !user.errors.empty?
    end   # should do

    should 'save and invite member - success' do
      user = User.new(email: "limesublime@example.com")
      assert user.save_and_invite_member
      assert user.errors.empty?
    end   # should do





  
  end   # context user

protected

    # ok to create user, member
#     @user   = User.new( user_params )
#     if @user.save_and_invite_member() && @user.create_member( member_params )


end  # class
