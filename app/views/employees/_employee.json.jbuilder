json.extract! employee, :id, :last_name, :first_name, :email, :title, :reports_to, :birth_date, :hire_date, :address, :city, :state, :country, :postal_code, :phone, :fax, :created_at, :updated_at
json.url employee_url(employee, format: :json)
