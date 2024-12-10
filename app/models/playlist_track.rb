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


  class << self
    def ransackable_attributes(auth_object = nil)
      ['id', 'playlist_id', 'track_id', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['playlist', 'track', 'genre', 'media_type', 'album', 'artist', 'invoice_lines', 'invoices', 'customers', 'support_reps']
    end
  end
end
