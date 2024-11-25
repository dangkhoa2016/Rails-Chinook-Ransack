class Album < ApplicationRecord
  belongs_to :artist
  has_many :tracks
  has_many :genres, through: :tracks, source: :genre
  has_many :media_types, through: :tracks, source: :media_type
  has_many :invoice_lines, through: :tracks
  has_many :invoices, through: :invoice_lines
  has_many :customers, through: :invoices
  has_many :playlist_tracks, through: :tracks
  has_many :playlists, through: :playlist_tracks
  has_many :support_reps, through: :customers, source: :support_rep


  def self.ransackable_attributes(auth_object = nil)
    ['id', 'title', 'artist_id', 'created_at', 'updated_at']
  end

  def self.ransackable_associations(auth_object = nil)
    ['artist', 'tracks', 'genres', 'media_types', 'invoice_lines', 'invoices', 'customers', 'playlist_tracks', 'playlists', 'support_reps']
  end
end
