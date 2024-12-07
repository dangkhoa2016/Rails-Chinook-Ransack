class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :invoice_lines
  has_many :tracks, through: :invoice_lines
  has_many :playlist_tracks, through: :tracks
  has_many :playlists, through: :playlist_tracks
  has_many :genres, through: :tracks, source: :genre
  has_many :media_types, through: :tracks, source: :media_type
  has_many :albums, through: :tracks, source: :album
  has_many :artists, through: :albums
  has_one :support_rep, through: :customer

  class << self
    def ransackable_attributes(auth_object = nil)
      ['id', 'customer_id', 'invoice_date', 'billing_address', 'billing_city', 'billing_state', 'billing_country', 'billing_postal_code', 'total', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['customer', 'invoice_lines', 'tracks', 'playlist_tracks', 'playlists', 'genres', 'media_types', 'albums', 'artists', 'support_rep']
    end
  end
end
