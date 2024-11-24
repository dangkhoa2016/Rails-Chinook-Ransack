class PlaylistTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :track
  has_one :genre, through: :track
  has_one :media_type, through: :track
  has_one :album, through: :track
  has_one :artist, through: :album
  has_many :invoice_lines, through: :track
  has_many :invoices, through: :invoice_lines
  has_many :customers, through: :invoices
  has_many :support_reps, through: :customers
end
