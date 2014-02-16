require 'test_helper'
 
# #############################################################################
# Note: this tests not only the methods in models/tenant.rb but
# also all of the milia-injected methods from base.rb
# #############################################################################
 
class TenantTest < ActiveSupport::TestCase


  context "a tenant" do

# ------------------------------------------------------------------------
    setup do
      @tenant =tenants( :tenant_1 )
      Tenant.set_current_tenant( @tenant.id )
    end

# #############################################################################
# #############################################################################
# ------------------------------------------------------------------------
# validate multi-tenanting structure
# ------------------------------------------------------------------------
    should have_db_column(:tenant_id)
    should have_db_column(:name)
    should have_many( :posts )
    should have_many( :zines )
    should have_many( :team_assets )
    should have_many( :teams )
    should have_many( :members )
    should have_and_belong_to_many( :users )

# ------------------------------------------------------------------------
# validate tenant creation callbacks, validators
# ------------------------------------------------------------------------
    should 'have a new_signups_not_permitted' do
      assert Tenant.respond_to? :new_signups_not_permitted?
      assert !Tenant.new_signups_not_permitted?( {} )
    end  # should do

    should 'create new tenant' do

      assert_difference( 'Tenant.count' ) do
          # setup new world
        tenant = Tenant.create_new_tenant( 
              {name:   "Mangoland"}, 
              {email:  "billybob@bob.com"}, 
              {coupon: "FreeTrial"}
        )
        assert_not_nil   tenant
        assert_kind_of   Tenant,tenant
        assert tenant.errors.empty?
        assert_equal  "Mangoland", tenant.name
      end 

    end  # should do
        
    should 'tenant signup callback' do 
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
      assert_difference( 'Member.count' ) do
        assert_nothing_raised  { 
          member = Tenant.tenant_signup(user, tenant)
          assert  member.errors.empty?
        }
      end  # new Member DB records created

      assert_equal  Member::DEFAULT_ADMIN[:first_name],member.first_name
      assert_equal  Member::DEFAULT_ADMIN[:last_name],member.last_name
      assert_equal  tenant.id, member.tenant_id
      assert_equal  user.member,member
       
    end  # should do
        
# #############################################################################
# ####  acts_as_universal_and_determines_tenant injected methods  #############
# #############################################################################
        
    should 'current_tenant_id - non nil' do
      tid = Tenant.current_tenant_id
      assert_kind_of  Integer,tid
      assert_equal  tenants( :tenant_1 ).id,tid
    end  # should do
        
    should 'current_tenant - nil' do
         # force the current_tenant to be nil
      Thread.current[:tenant_id] = nil
         
      tenant = Tenant.current_tenant
      assert_nil  tenant
      
    end  # should do
        
    should 'current_tenant - valid tid' do
      tenant = Tenant.current_tenant
      assert_kind_of  Tenant,tenant
      assert_equal  tenants( :tenant_1 ),tenant
    end  # should do
        
    should 'current_tenant - invalid tid' do
         # force the current_tenant to be nil
      Thread.current[:tenant_id] = 500

      assert_nothing_raised  { 
        assert_nil  Tenant.current_tenant
      }

    end  # should do
         
    should 'set current tenant - tenant obj' do
      assert_equal  tenants( :tenant_1 ).id, Tenant.current_tenant_id
      Tenant.set_current_tenant( tenants( :tenant_3 ) )
      assert_equal  tenants( :tenant_3 ).id, Tenant.current_tenant_id
    end  # should do
         
    should 'set current tenant - tenant id' do
      assert_equal  tenants( :tenant_1 ).id, Tenant.current_tenant_id
      Tenant.set_current_tenant( tenants( :tenant_3 ).id )
      assert_equal  tenants( :tenant_3 ).id, Tenant.current_tenant_id
    end  # should do
         
    should 'NOT set current tenant - invalid arg' do
      assert_equal  tenants( :tenant_1 ).id, Tenant.current_tenant_id
      assert_raise(ArgumentError) { 
        Tenant.set_current_tenant( '2' )
      }
      assert_equal  tenants( :tenant_1 ).id, Tenant.current_tenant_id
    end  # should do

RESTRICT_SNIPPET = 'posts.tenant_id = 1 AND zines.tenant_id = 1'
    should 'prepare a restrict tenant snippet' do
      assert_equal RESTRICT_SNIPPET, Tenant.where_restrict_tenant( Post, Zine )
    end  # should do

    should 'clear tenant.users when tenant destroyed' do
      target = tenants(:tenant_2)
      Tenant.set_current_tenant( target )
      quentin = users(:quentin)
      assert_equal 2,quentin.tenants.count

      assert_difference( "Tenant.count", -1 ) do
        target.destroy
      end 

      quentin.reload
      assert_equal 1,quentin.tenants.count
 
    end  # should do
        
        
# #############################################################################
# ####  acts_as_tenant injected methods  #############
# #############################################################################
        
    should "raise exception if tenant is different" do
      target = members(:quentin_1)
         # now force tenant to invalid
      Tenant.set_current_tenant( 0 )
      
      assert_raise(::Milia::Control::InvalidTenantAccess,
         "InvalidTenantAccess if tenants dont match"){
         target.update_attributes( :first_name => "duck walk" )
      }
     end  # should do

    should 'raise exception if tenanted tid not nil - destroy' do
      target = members(:quentin_1)
      assert_no_difference('Member.count') do
        assert_raise(::Milia::Control::InvalidTenantAccess) {
          target.tenant_id = 3
          target.destroy
        }
      end  # no diff do
    end  # should do
        
# #############################################################################
# ####  acts_as_universal injected methods  #############
# #############################################################################
    should 'always force universal tenant id to nil' do 
        # setup new world
      tenant = Tenant.create_new_tenant( 
            {name:   "Mangoland", tenant_id: 1}, 
            {email:  "billybob@bob.com"}, 
            {coupon: "FreeTrial"}
      )
      assert tenant.errors.empty?
      assert_nil  tenant.tenant_id
    end  # should do
 
 
    should 'raise exception if tid not nil - save' do
      tenant = tenants(:tenant_1)
      assert_raise(::Milia::Control::InvalidTenantAccess) {
        tenant.update_attributes( tenant_id: 3, name: 'wild blue2' )
      }

    end  # should do
 
    should 'raise exception if tid not nil - destroy' do
      tenant = tenants(:tenant_1)
      assert_no_difference('Tenant.count') do
        assert_raise(::Milia::Control::InvalidTenantAccess) {
          tenant.tenant_id = 3
          tenant.destroy
        }
      end  # no diff do
    end  # should do
 
# #############################################################################

  end  # context
 
# #############################################################################
end  # class test
