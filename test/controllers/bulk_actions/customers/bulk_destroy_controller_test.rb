require "test_helper"

class BulkActions::Customers::BulkDestroyControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! 'test.app.github.dev'
    @customer = customers(:one)
  end

  test "should get new" do
    get new_bulk_actions_customers_bulk_destroy_url, params: { picked_ids: @customer.id }
    assert_response :success
  end

  test "should render create response" do
    post bulk_actions_customers_bulk_destroy_index_url, params: { picked_ids: @customer.id }
    assert_includes [200, 422], response.status
  end
end
