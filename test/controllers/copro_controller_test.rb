require 'test_helper'

class CoproControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get copro_login_url
    assert_response :success
  end

end
