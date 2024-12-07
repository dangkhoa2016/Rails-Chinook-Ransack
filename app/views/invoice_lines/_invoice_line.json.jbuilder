json.extract! invoice_line, :id, :invoice_id, :track_id, :unit_price, :quantity, :created_at, :updated_at
json.url invoice_line_url(invoice_line, format: :json)
