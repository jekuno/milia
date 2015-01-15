require 'test_helper'
 
# #############################################################################
# Note: this tests not only the methods in models/user.rb but
# also all of the milia-injected methods from base.rb for
# acts_as_universal_and_determines_account
# #############################################################################
 
class UserTest < ActiveSupport::TestCase

  context "a user" do
    
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
    setup do
      Tenant.set_current_tenant( tenants( :tenant_1 ).id )
      @user = users(:quentin)
    end

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
    should have_one( :member )
    should have_many( :tenanted_members )
    should have_and_belong_to_many( :tenants )
    should_not allow_value("wild blue").for(:email)
    
    should have_db_column(:tenant_id)
    should have_db_column(:skip_confirm_change_password).with_options(default: 'f')

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

# #############################################################################
# #############################################################################


    should 'NOT create new user when invalid current tenant - string' do
              # force the current_tenant to be unexpected object
      Thread.current[:tenant_id] = 'peanut clusters'
      
      assert_no_difference("User.count") do
        assert_raise(::Milia::Control::InvalidTenantAccess,
          "no existing valid current tenant")   {
   
            # setup new user
          user = User.new(email: "limesublime@example.com")
          user.save_and_invite_member
        }
      end  # no difference
 
    end  # should do

    should 'NOT create new user when invalid current tenant - nil' do
              # force the current_tenant to be nil
      Thread.current[:tenant_id] = nil
      
      assert_no_difference("User.count") do
        assert_raise(::Milia::Control::InvalidTenantAccess,
          "no existing valid current tenant")   {
   
            # setup new user
          user = User.new(email: "limesublime@example.com")
          user.save_and_invite_member
        }
      end  # no difference
 
    end  # should do

    should 'NOT create new user when invalid current tenant - zero' do
              # force the current_tenant to be 0
      Thread.current[:tenant_id] = 0
      
      assert_no_difference("User.count") do
        assert_raise(::Milia::Control::InvalidTenantAccess,
          "no existing valid current tenant")   {
   
            # setup new user
          user = User.new(email: "limesublime@example.com")
          user.save_and_invite_member
        }
      end  # no difference
 
    end  # should do

# this validates both the before_create and after_create for users
    should 'create new user when valid current tenant' do
      tenant = tenants(:tenant_1)
      assert_equal 1,tenant.users.count
      
      assert_difference("User.count") do
        assert_nothing_raised(::Milia::Control::InvalidTenantAccess,
          "no existing valid current tenant")   {
   
            # setup new user
          user = User.new(email: "limesublime@example.com")
          user.save_and_invite_member
        }
      end  # no difference

      tenant.reload
      assert_equal 2,tenant.users.count
 
    end  # should do


    should 'destroy a user and clear its tenants habtm' do
      tenant = tenants(:tenant_2)
      Tenant.set_current_tenant( tenant )
      quentin = users(:quentin)
      assert_equal 3,tenant.users.count
      quentin.destroy
      tenant.reload
      assert_equal 2,tenant.users.count
    end # should do



    # ok to create user, member
#     @user   = User.new( user_params )
#     if @user.save_and_invite_member() && @user.create_member( member_params )

  
  end   # context user

end  # class
