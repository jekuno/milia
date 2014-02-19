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

  should "get show with login" do
    sign_in( users( :quentin ) )
    get :show
    assert_response :success
    sign_out( users( :quentin ) )
  end  # should do

  should 'not get show without login' do
    assert_raise(ArgumentError, 'uncaught throw :warden'){
      get :show
    }
    assert_response :success
  end  # should do

  should 'reset tenant' do
    assert Tenant.current_tenant_id
    @controller.__milia_reset_tenant!   # invoke the private method
    assert_nil Tenant.current_tenant_id

  end  # should do

  should 'change tenant' do
    assert_equal 1,Tenant.current_tenant_id
    @controller.__milia_change_tenant!(2)   # invoke the private method
    assert_equal 2,Tenant.current_tenant_id
  end  # should do

  should 'trace tenanting' do
    ::Milia.trace_on = true
    @controller.trace_tenanting( "wild blue" )
    ::Milia.trace_on = false
    @controller.trace_tenanting( "duck walk" )
  end  # should do

  should 'initiate tenant' do
    @controller.initiate_tenant( tenants(:tenant_2) )
    assert_equal 2,Tenant.current_tenant_id
  end  # should do

  should 'redirect back' do
       # alter the code to invoke redirect_back
    @controller.class.module_eval(
      %q{
        def index()
          redirect_back
        end
      }
    )

       # now test it
    get :index
    assert_response :redirect
    assert_redirected_to  root_url()

  end  # should do

  should 'prep signup view' do
    assert_nil  @controller.instance_eval( "@tenant" )
    @controller.prep_signup_view( 
        { name: 'Mangoland' }, 
        {email: 'billybob@bob.com', password: 'monkeymocha', password_confirmation: 'monkeymocha'} 
    )
    assert_equal 'Mangoland', @controller.instance_eval( "@tenant" ).name
  end  # should do

  should 'raise max_tenants exception' do
    @controller.instance_eval( 
      %q{
        raise ::Milia::Control::MaxTenantExceeded
      }
    )
  end  # should do

  end  # context

end  # end class test
