class Playlist < ApplicationRecord
  has_many :playlist_tracks
  has_many :tracks, through: :playlist_tracks
  has_many :albums, through: :tracks, source: :album
  has_many :artists, through: :albums
  has_many :genres, through: :tracks, source: :genre
  has_many :media_types, through: :tracks, source: :media_type
  has_many :invoice_lines, through: :tracks
  has_many :invoices, through: :invoice_lines
  has_many :customers, through: :invoices
  has_many :support_reps, through: :customers
end
