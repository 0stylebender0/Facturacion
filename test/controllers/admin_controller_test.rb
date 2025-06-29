require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get admin_home_url
    assert_response :success
  end

  test "should get stock" do
    get admin_stock_url
    assert_response :success
  end

  test "should get impuesto" do
    get admin_impuesto_url
    assert_response :success
  end
end
