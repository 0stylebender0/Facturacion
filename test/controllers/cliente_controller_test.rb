require "test_helper"

class ClienteControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get cliente_home_url
    assert_response :success
  end

  test "should get factura" do
    get cliente_factura_url
    assert_response :success
  end
end
