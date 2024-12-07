class InvoiceLine < ApplicationRecord
  belongs_to :invoice
  belongs_to :track
  has_one :customer, through: :invoice
  has_one :support_rep, through: :customer
  has_one :album, through: :track
  has_one :artist, through: :album
  has_one :genre, through: :track
  has_one :media_type, through: :track
  has_many :playlist_tracks, through: :track
  has_many :playlists, through: :playlist_tracks

  class << self
    def ransackable_attributes(auth_object = nil)
      ['id', 'invoice_id', 'track_id', 'unit_price', 'quantity', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['invoice', 'track', 'customer', 'support_rep', 'album', 'artist', 'genre', 'media_type', 'playlist_tracks', 'playlists']
    end
  end
end
