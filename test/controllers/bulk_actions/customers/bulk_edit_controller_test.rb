require "test_helper"

class BulkActions::Customers::BulkEditControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! 'test.app.github.dev'
    @customer = customers(:one)
  end

  test "should get new" do
    get new_bulk_actions_customers_bulk_edit_url, params: { picked_ids: @customer.id }
    assert_response :success
  end

  test "should update selected records" do
    post bulk_actions_customers_bulk_edit_index_url,
      params: { picked_ids: @customer.id, customer: { company: 'Bulk Updated Company' } }

    assert_response :success
    assert_equal 'Bulk Updated Company', @customer.reload.company
  end

  test "should return error when no fields selected" do
    post bulk_actions_customers_bulk_edit_index_url, params: { picked_ids: @customer.id }
    assert_response :unprocessable_entity
  end
end
