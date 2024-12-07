json.extract! customer, :id, :first_name, :last_name, :company, :address, :city, :state, :country, :postal_code, :phone, :fax, :email, :support_rep_id, :created_at, :updated_at
json.url customer_url(customer, format: :json)
