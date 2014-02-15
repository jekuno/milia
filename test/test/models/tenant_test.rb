require 'test_helper'

class TenantTest < ActiveSupport::TestCase


  context "a tenant" do
    
    setup do
      @tenant =tenants( :tenant_1 )
      Tenant.set_current_tenant( @tenant.id )
    end

# validate multi-tenanting structure
    should have_db_column(:tenant_id)
    should have_db_column(:name)
    should have_many( :posts )
    should have_many( :zines )
    should have_many( :team_assets )
    should have_many( :teams )
    should have_many( :members )

# validate tenant creation callbacks, validators
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

    end  # should do
         
        
#     should "exception if tenant is different" do
#       ActiveSupport::TestCase.reset_tenant
#       
#       assert_raise(::Milia::Control::InvalidTenantAccess,
#          "InvalidTenantAccess if tenants dont match"){
#          @post.update_attributes( :content => "duck walk" )
#       }
#     end    
 

  end  # context

end  # class test
