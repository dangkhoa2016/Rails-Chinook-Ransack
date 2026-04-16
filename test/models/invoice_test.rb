require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  # --- Validations ---
  test "valid with all required fields" do
    assert invoices(:invoice_one).valid?
  end

  test "invalid without invoice_date" do
    invoice = invoices(:invoice_one)
    invoice.invoice_date = nil
    assert_not invoice.valid?
  end

  test "invalid without billing_city" do
    invoice = invoices(:invoice_one)
    invoice.billing_city = nil
    assert_not invoice.valid?
  end

  test "invalid without billing_country" do
    invoice = invoices(:invoice_one)
    invoice.billing_country = nil
    assert_not invoice.valid?
  end

  # --- Associations ---
  test "belongs to customer" do
    assert_equal customers(:john_doe), invoices(:invoice_one).customer
  end

  test "has many invoice_lines" do
    assert_equal 2, invoices(:invoice_one).invoice_lines.count
  end

  test "has many tracks through invoice_lines" do
    assert_equal 2, invoices(:invoice_one).tracks.count
  end

  # --- count_by_model_ids ---
  test "count_by_model_ids returns correct invoice counts per customer" do
    customer_id = customers(:john_doe).id
    result = Invoice.count_by_model_ids(:customer, [customer_id])
    assert_equal 1, result[customer_id]
  end

  # --- display_invoice_lines_count ---
  test "display_invoice_lines_count uses attr_accessor when set" do
    invoice = invoices(:invoice_one)
    invoice.invoice_lines_count = 5
    assert_equal 5, invoice.display_invoice_lines_count
  end

  test "display_invoice_lines_count queries db when not set" do
    assert_equal 2, invoices(:invoice_one).display_invoice_lines_count
  end
end
