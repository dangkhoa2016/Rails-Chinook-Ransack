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
end
