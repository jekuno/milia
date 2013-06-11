require 'test_helper'

class TenantTest < ActiveSupport::TestCase


  context "a user" do
    
    setup do
      setup_world()
      @user = Factory( :user )
      @post = Factory( :post )
      ActiveSupport::TestCase.reset_tenant()    # clear the tenant for testing
    end

        
    should "exception if tenant is different" do
      ActiveSupport::TestCase.reset_tenant
      
puts "*********** thread:#{Thread.current[:tenant_id]}\tpost:#{@post.tenant_id} *******************************************"

      assert_raise(::Milia::Control::InvalidTenantAccess,
         "InvalidTenantAccess if tenants dont match"){
         @post.update_attributes( :content => "duck walk" )
      }
    end    
 

  end  # context

end  # class test
