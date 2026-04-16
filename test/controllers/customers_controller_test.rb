require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:john_doe)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get customers_url
    assert_redirected_to new_user_session_path
  end

  test "GET index returns success" do
    get customers_url
    assert_response :success
  end

  test "GET show returns success" do
    get customer_url(@customer)
    assert_response :success
  end

  test "GET new returns success" do
    get new_customer_url
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("Customer.count") do
      post customers_url, params: { customer: {
        first_name: "New", last_name: "Customer",
        email: "new@example.com", address: "123 St",
        city: "NYC", state: "NY", country: "USA",
        postal_code: "10001", support_rep_id: employees(:sales_agent).id
      }}
    end
    assert_redirected_to customer_url(Customer.last)
  end

  test "PATCH update with valid params" do
    patch customer_url(@customer), params: { customer: { first_name: "Updated" } }
    assert_redirected_to customer_url(@customer)
    assert_equal "Updated", @customer.reload.first_name
  end

  test "DELETE destroy removes customer" do
    customer = Customer.create!(
      first_name: "Del", last_name: "Me", email: "del@example.com",
      address: "1 St", city: "NYC", state: "NY", country: "USA",
      postal_code: "10001", support_rep: employees(:sales_agent)
    )
    assert_difference("Customer.count", -1) do
      delete customer_url(customer)
    end
    assert_redirected_to customers_url
  end
end
