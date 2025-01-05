class AddIndexToAllTables < ActiveRecord::Migration[7.1]
  def change
    add_index :albums, :title
    add_index :albums, :created_at
    add_index :albums, :updated_at

    add_index :artists, :name
    add_index :artists, :created_at
    add_index :artists, :updated_at

    add_index :customers, :first_name
    add_index :customers, :last_name
    add_index :customers, :company
    add_index :customers, :address
    add_index :customers, :city
    add_index :customers, :state
    add_index :customers, :country
    add_index :customers, :postal_code
    add_index :customers, :phone
    add_index :customers, :fax
    add_index :customers, :email
    add_index :customers, :created_at
    add_index :customers, :updated_at

    add_index :employees, :first_name
    add_index :employees, :last_name
    add_index :employees, :title
    add_index :employees, :reports_to
    add_index :employees, :birth_date
    add_index :employees, :hire_date
    add_index :employees, :address
    add_index :employees, :city
    add_index :employees, :state
    add_index :employees, :country
    add_index :employees, :postal_code
    add_index :employees, :phone
    add_index :employees, :fax
    add_index :employees, :email
    add_index :employees, :created_at
    add_index :employees, :updated_at

    add_index :genres, :name
    add_index :genres, :created_at
    add_index :genres, :updated_at

    add_index :invoice_lines, :quantity
    add_index :invoice_lines, :unit_price
    add_index :invoice_lines, :created_at
    add_index :invoice_lines, :updated_at

    add_index :invoices, :invoice_date
    add_index :invoices, :billing_address
    add_index :invoices, :billing_city
    add_index :invoices, :billing_state
    add_index :invoices, :billing_country
    add_index :invoices, :billing_postal_code
    add_index :invoices, :total
    add_index :invoices, :created_at
    add_index :invoices, :updated_at

    add_index :media_types, :name
    add_index :media_types, :created_at
    add_index :media_types, :updated_at

    add_index :playlists, :name
    add_index :playlists, :created_at
    add_index :playlists, :updated_at

    add_index :tracks, :name
    add_index :tracks, :composer
    add_index :tracks, :milliseconds
    add_index :tracks, :unit_price
    add_index :tracks, :bytes
    add_index :tracks, :created_at
    add_index :tracks, :updated_at
  end
end
