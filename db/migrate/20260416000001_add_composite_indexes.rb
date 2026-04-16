class AddCompositeIndexes < ActiveRecord::Migration[7.1]
  def change
    # Invoices: thường filter/sort theo customer + date hoặc total
    add_index :invoices, [:customer_id, :invoice_date], if_not_exists: true
    add_index :invoices, [:customer_id, :total], if_not_exists: true

    # Tracks: thường filter theo album + genre hoặc media_type
    add_index :tracks, [:album_id, :genre_id], if_not_exists: true
    add_index :tracks, [:album_id, :media_type_id], if_not_exists: true

    # InvoiceLines: thường query theo invoice + track
    add_index :invoice_lines, [:invoice_id, :track_id], if_not_exists: true

    # Albums: thường query theo artist + thời gian tạo
    add_index :albums, [:artist_id, :created_at], if_not_exists: true

    # PlaylistTracks: thường query theo playlist + track (cũng đảm bảo không duplicate)
    add_index :playlist_tracks, [:playlist_id, :track_id], if_not_exists: true

    # Employees: hierarchy query (ai báo cáo cho ai)
    add_index :employees, [:reports_to, :hire_date], if_not_exists: true
  end
end
