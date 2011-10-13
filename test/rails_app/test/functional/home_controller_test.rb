require 'test_helper'
require 'unit/helpers/home_helper_test'

class HomeControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
  end

end
