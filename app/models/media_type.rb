class MediaType < ApplicationRecord
  has_many :tracks
  has_many :albums, through: :tracks, source: :album
  has_many :artists, through: :albums
  has_many :genres, through: :tracks, source: :genre
  has_many :invoice_lines, through: :tracks
  has_many :invoices, through: :invoice_lines
  has_many :customers, through: :invoices
  has_many :playlist_tracks, through: :tracks
  has_many :playlists, through: :playlist_tracks
  has_many :support_reps, through: :customers

  def self.ransackable_attributes(auth_object = nil)
    ['id', 'name', 'created_at', 'updated_at']
  end

  def self.ransackable_associations(auth_object = nil)
    ['tracks', 'albums', 'artists', 'genres', 'invoice_lines', 'invoices', 'customers', 'playlist_tracks', 'playlists', 'support_reps']
  end
end
