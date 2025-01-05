# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_01_05_095242) do
  create_table "albums", force: :cascade do |t|
    t.string "title"
    t.integer "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_albums_on_artist_id"
    t.index ["created_at"], name: "index_albums_on_created_at"
    t.index ["title"], name: "index_albums_on_title"
    t.index ["updated_at"], name: "index_albums_on_updated_at"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_artists_on_created_at"
    t.index ["name"], name: "index_artists_on_name"
    t.index ["updated_at"], name: "index_artists_on_updated_at"
  end

  create_table "customers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "company"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.string "phone"
    t.string "fax"
    t.string "email"
    t.integer "support_rep_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_customers_on_address"
    t.index ["city"], name: "index_customers_on_city"
    t.index ["company"], name: "index_customers_on_company"
    t.index ["country"], name: "index_customers_on_country"
    t.index ["created_at"], name: "index_customers_on_created_at"
    t.index ["email"], name: "index_customers_on_email"
    t.index ["fax"], name: "index_customers_on_fax"
    t.index ["first_name"], name: "index_customers_on_first_name"
    t.index ["last_name"], name: "index_customers_on_last_name"
    t.index ["phone"], name: "index_customers_on_phone"
    t.index ["postal_code"], name: "index_customers_on_postal_code"
    t.index ["state"], name: "index_customers_on_state"
    t.index ["support_rep_id"], name: "index_customers_on_support_rep_id"
    t.index ["updated_at"], name: "index_customers_on_updated_at"
  end

  create_table "employees", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "email"
    t.string "title"
    t.integer "reports_to"
    t.date "birth_date"
    t.datetime "hire_date"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.string "phone"
    t.string "fax"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_employees_on_address"
    t.index ["birth_date"], name: "index_employees_on_birth_date"
    t.index ["city"], name: "index_employees_on_city"
    t.index ["country"], name: "index_employees_on_country"
    t.index ["created_at"], name: "index_employees_on_created_at"
    t.index ["email"], name: "index_employees_on_email"
    t.index ["fax"], name: "index_employees_on_fax"
    t.index ["first_name"], name: "index_employees_on_first_name"
    t.index ["hire_date"], name: "index_employees_on_hire_date"
    t.index ["last_name"], name: "index_employees_on_last_name"
    t.index ["phone"], name: "index_employees_on_phone"
    t.index ["postal_code"], name: "index_employees_on_postal_code"
    t.index ["reports_to"], name: "index_employees_on_reports_to"
    t.index ["state"], name: "index_employees_on_state"
    t.index ["title"], name: "index_employees_on_title"
    t.index ["updated_at"], name: "index_employees_on_updated_at"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_genres_on_created_at"
    t.index ["name"], name: "index_genres_on_name"
    t.index ["updated_at"], name: "index_genres_on_updated_at"
  end

  create_table "invoice_lines", force: :cascade do |t|
    t.integer "invoice_id"
    t.integer "track_id"
    t.decimal "unit_price", precision: 10, scale: 2
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_invoice_lines_on_created_at"
    t.index ["invoice_id"], name: "index_invoice_lines_on_invoice_id"
    t.index ["quantity"], name: "index_invoice_lines_on_quantity"
    t.index ["track_id"], name: "index_invoice_lines_on_track_id"
    t.index ["unit_price"], name: "index_invoice_lines_on_unit_price"
    t.index ["updated_at"], name: "index_invoice_lines_on_updated_at"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "customer_id"
    t.datetime "invoice_date"
    t.string "billing_address"
    t.string "billing_city"
    t.string "billing_state"
    t.string "billing_country"
    t.string "billing_postal_code"
    t.decimal "total", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billing_address"], name: "index_invoices_on_billing_address"
    t.index ["billing_city"], name: "index_invoices_on_billing_city"
    t.index ["billing_country"], name: "index_invoices_on_billing_country"
    t.index ["billing_postal_code"], name: "index_invoices_on_billing_postal_code"
    t.index ["billing_state"], name: "index_invoices_on_billing_state"
    t.index ["created_at"], name: "index_invoices_on_created_at"
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.index ["invoice_date"], name: "index_invoices_on_invoice_date"
    t.index ["total"], name: "index_invoices_on_total"
    t.index ["updated_at"], name: "index_invoices_on_updated_at"
  end

  create_table "media_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_media_types_on_created_at"
    t.index ["name"], name: "index_media_types_on_name"
    t.index ["updated_at"], name: "index_media_types_on_updated_at"
  end

  create_table "playlist_tracks", force: :cascade do |t|
    t.integer "playlist_id"
    t.integer "track_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playlist_id"], name: "index_playlist_tracks_on_playlist_id"
    t.index ["track_id"], name: "index_playlist_tracks_on_track_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_playlists_on_created_at"
    t.index ["name"], name: "index_playlists_on_name"
    t.index ["updated_at"], name: "index_playlists_on_updated_at"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "name"
    t.integer "album_id"
    t.integer "media_type_id"
    t.integer "genre_id"
    t.string "composer"
    t.integer "milliseconds"
    t.integer "bytes"
    t.decimal "unit_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_tracks_on_album_id"
    t.index ["bytes"], name: "index_tracks_on_bytes"
    t.index ["composer"], name: "index_tracks_on_composer"
    t.index ["created_at"], name: "index_tracks_on_created_at"
    t.index ["genre_id"], name: "index_tracks_on_genre_id"
    t.index ["media_type_id"], name: "index_tracks_on_media_type_id"
    t.index ["milliseconds"], name: "index_tracks_on_milliseconds"
    t.index ["name"], name: "index_tracks_on_name"
    t.index ["unit_price"], name: "index_tracks_on_unit_price"
    t.index ["updated_at"], name: "index_tracks_on_updated_at"
  end

  add_foreign_key "albums", "artists"
  add_foreign_key "customers", "employees", column: "support_rep_id"
  add_foreign_key "invoice_lines", "invoices"
  add_foreign_key "invoice_lines", "tracks"
  add_foreign_key "invoices", "customers"
  add_foreign_key "playlist_tracks", "playlists"
  add_foreign_key "playlist_tracks", "tracks"
  add_foreign_key "tracks", "albums"
  add_foreign_key "tracks", "genres"
  add_foreign_key "tracks", "media_types"
end
