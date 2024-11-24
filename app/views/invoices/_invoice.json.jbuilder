json.extract! invoice, :id, :customer_id, :invoice_date, :billing_address, :billing_city, :billing_state, :billing_country, :billing_postal_code, :total, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
