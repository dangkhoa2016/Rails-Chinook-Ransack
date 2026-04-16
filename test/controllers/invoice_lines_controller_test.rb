require "test_helper"

class InvoiceLinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice_line = invoice_lines(:line_one)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get invoice_lines_url
    assert_redirected_to new_user_session_path
  end

  test "GET index returns success" do
    get invoice_lines_url
    assert_response :success
  end

  test "GET show returns success" do
    get invoice_line_url(@invoice_line)
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("InvoiceLine.count") do
      post invoice_lines_url, params: { invoice_line: {
        invoice_id: invoices(:invoice_two).id,
        track_id: tracks(:master_of_puppets_track).id,
        unit_price: 0.99,
        quantity: 1
      }}
    end
    assert_redirected_to invoice_line_url(InvoiceLine.last)
  end

  test "PATCH update with valid params" do
    patch invoice_line_url(@invoice_line), params: { invoice_line: { quantity: 2 } }
    assert_redirected_to invoice_line_url(@invoice_line)
    assert_equal 2, @invoice_line.reload.quantity
  end

  test "DELETE destroy removes invoice_line" do
    line = InvoiceLine.create!(
      invoice: invoices(:invoice_two),
      track: tracks(:back_in_black_track),
      unit_price: 0.99, quantity: 1
    )
    assert_difference("InvoiceLine.count", -1) do
      delete invoice_line_url(line)
    end
    assert_redirected_to invoice_lines_url
  end
end
