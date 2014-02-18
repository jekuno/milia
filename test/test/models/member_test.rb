require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  
  context "a member" do
    
    setup do
      Tenant.set_current_tenant( tenants( :tenant_1 ).id )
      @member = members(:quentin_1)
    end

# validate multi-tenanting structure
    should have_db_column(:tenant_id)
    should "define the current tenant" do
      assert  Thread.current[:tenant_id]
    end
    should "match the current tenant" do
      a_member = Member.first
      assert_equal  a_member.tenant_id, Thread.current[:tenant_id]
    end

# validate the model
    should belong_to( :user )
    should have_many( :posts )
    should have_many( :zines ).through( :posts )
    should have_many( :team_assets )
    should have_many( :teams ).through( :team_assets )

# validate specific member methods
    should 'create new member for new admin' do
        # setup new world
      tenant = Tenant.create_new_tenant( 
            {name:   "Mangoland"}, 
            {email:  "billybob@bob.com"}, 
            {coupon: "FreeTrial"}
      )
      assert tenant.errors.empty?
      Tenant.set_current_tenant( tenant )  # change world to new tenant

        # setup new user
      user = User.new(email: "limesublime@example.com")
      assert user.save_and_invite_member
      assert user.errors.empty?
        
        # setup new member
      member = nil
      assert_nothing_raised  { 
        member = Member.create_org_admin( user )
        assert  member.errors.empty?
      }

      assert_equal  Member::DEFAULT_ADMIN[:first_name],member.first_name
      assert_equal  Member::DEFAULT_ADMIN[:last_name],member.last_name
      assert_equal  tenant.id, member.tenant_id
      assert_equal  user.member,member

    end   # should do

    should 'create new member for existing tenant' do
      tenant = tenants( :tenant_1 )
      user = users( :quentin )
      member = Member.create_new_member( user, {last_name: 'Blue', first_name: 'Wild'} )
      assert  member.errors.empty?
      assert_equal  tenant.id, member.tenant_id
      assert_equal  user.member,member
    end  # should do

    should "not get any non-world member" do
       x = users(:demarcus)
       assert   x.member.nil?
    end
    
  end   # context member
  
end #   class member
