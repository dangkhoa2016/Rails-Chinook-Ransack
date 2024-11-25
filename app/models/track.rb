class Track < ApplicationRecord
  belongs_to :album
  belongs_to :media_type
  belongs_to :genre
  has_many :invoice_lines
  has_many :invoices, through: :invoice_lines
  has_many :playlist_tracks
  has_many :playlists, through: :playlist_tracks
  has_many :customers, through: :invoices
  has_many :artists, through: :album
  has_many :support_reps, through: :customers

  def self.ransackable_attributes(auth_object = nil)
    ['id', 'name', 'composer', 'milliseconds', 'bytes', 'unit_price', 'created_at', 'updated_at']
  end

  def self.ransackable_associations(auth_object = nil)
    ['album', 'media_type', 'genre', 'invoice_lines', 'invoices', 'playlist_tracks', 'playlists', 'customers', 'artists', 'support_reps']
  end
end
