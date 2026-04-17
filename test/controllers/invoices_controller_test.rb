require "test_helper"

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice = invoices(:invoice_one)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get invoices_url
    assert_redirected_to new_user_session_path
  end

  # --- Authorization ---
  test "regular user can view index" do
    sign_in_regular_user
    get invoices_url
    assert_response :success
  end

  test "regular user can view show" do
    sign_in_regular_user
    get invoice_url(@invoice)
    assert_response :success
  end

  test "regular user cannot access new" do
    sign_in_regular_user
    get new_invoice_url
    assert_redirected_to root_path
  end

  test "regular user cannot create invoice" do
    sign_in_regular_user
    assert_no_difference("Invoice.count") do
      post invoices_url, params: { invoice: { billing_city: "Hack" } }
    end
    assert_redirected_to root_path
  end

  test "regular user cannot update invoice" do
    sign_in_regular_user
    patch invoice_url(@invoice), params: { invoice: { billing_city: "Hacked" } }
    assert_redirected_to root_path
    assert_not_equal "Hacked", @invoice.reload.billing_city
  end

  test "regular user cannot destroy invoice" do
    sign_in_regular_user
    assert_no_difference("Invoice.count") do
      delete invoice_url(@invoice)
    end
    assert_redirected_to root_path
  end

  # --- CRUD (admin) ---
  test "GET index returns success" do
    get invoices_url
    assert_response :success
  end

  test "GET show returns success" do
    get invoice_url(@invoice)
    assert_response :success
  end

  test "GET new returns success" do
    get new_invoice_url
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("Invoice.count") do
      post invoices_url, params: { invoice: {
        customer_id: customers(:john_doe).id,
        invoice_date: Time.current,
        billing_address: "123 Main St",
        billing_city: "New York",
        billing_state: "NY",
        billing_country: "USA",
        billing_postal_code: "10001",
        total: 9.99
      }}
    end
    assert_redirected_to invoice_url(Invoice.last)
  end

  test "POST create with invalid params renders new" do
    assert_no_difference("Invoice.count") do
      post invoices_url, params: { invoice: { billing_city: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "PATCH update with valid params" do
    patch invoice_url(@invoice), params: { invoice: { billing_city: "Boston" } }
    assert_redirected_to invoice_url(@invoice)
    assert_equal "Boston", @invoice.reload.billing_city
  end

  test "DELETE destroy removes invoice" do
    invoice = Invoice.create!(
      customer: customers(:john_doe),
      invoice_date: Time.current,
      billing_address: "1 St", billing_city: "NYC",
      billing_state: "NY", billing_country: "USA",
      billing_postal_code: "10001", total: 1.0
    )
    assert_difference("Invoice.count", -1) do
      delete invoice_url(invoice)
    end
    assert_redirected_to invoices_url
  end

  test "GET json_list_for_select_element with numeric keyword" do
    get json_list_for_select_element_invoices_url, params: { keyword: "1" }
    assert_response :success
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end
end
