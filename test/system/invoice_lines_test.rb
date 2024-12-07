require "application_system_test_case"

class InvoiceLinesTest < ApplicationSystemTestCase
  setup do
    @invoice_line = invoice_lines(:one)
  end

  test "visiting the index" do
    visit invoice_lines_url
    assert_selector "h1", text: "Invoice lines"
  end

  test "should create invoice line" do
    visit invoice_lines_url
    click_on "New invoice line"

    fill_in "Invoice", with: @invoice_line.invoice_id
    fill_in "Quantity", with: @invoice_line.quantity
    fill_in "Track", with: @invoice_line.track_id
    fill_in "Unit price", with: @invoice_line.unit_price
    click_on "Create Invoice line"

    assert_text "Invoice line was successfully created"
    click_on "Back"
  end

  test "should update Invoice line" do
    visit invoice_line_url(@invoice_line)
    click_on "Edit this invoice line", match: :first

    fill_in "Invoice", with: @invoice_line.invoice_id
    fill_in "Quantity", with: @invoice_line.quantity
    fill_in "Track", with: @invoice_line.track_id
    fill_in "Unit price", with: @invoice_line.unit_price
    click_on "Update Invoice line"

    assert_text "Invoice line was successfully updated"
    click_on "Back"
  end

  test "should destroy Invoice line" do
    visit invoice_line_url(@invoice_line)
    click_on "Destroy this invoice line", match: :first

    assert_text "Invoice line was successfully destroyed"
  end
end
