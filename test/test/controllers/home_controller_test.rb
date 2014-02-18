require 'ctlr_test_helper'

class HomeControllerTest < ActionController::TestCase
    
  context 'home ctlr' do
    setup do
      Tenant.set_current_tenant( tenants( :tenant_1 ).id )
    end

  should "get index" do
    get :index
    assert_response :success
  end

  should "get show" do
    sign_in( users( :quentin ) )
    get :show
    assert_response :success
    sign_out( users( :quentin ) )
  end  # should do

  end  # context

end  # end class test
