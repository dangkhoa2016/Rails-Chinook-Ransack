class Customer < ApplicationRecord
  belongs_to :support_rep, class_name: 'Employee', foreign_key: 'support_rep_id'
  has_many :invoices
  has_many :invoice_lines, through: :invoices
  has_many :tracks, through: :invoice_lines
  has_many :albums, through: :tracks
  has_many :artists, through: :albums
  has_many :genres, through: :tracks, source: :genre
  has_many :media_types, through: :tracks, source: :media_type
  has_many :playlist_tracks, through: :tracks
  has_many :playlists, through: :playlist_tracks

  def full_name
    [first_name, last_name].join(' ')
  end
  
  class << self
    def ransackable_attributes(auth_object = nil)
      ['id', 'first_name', 'last_name', 'company', 'address', 'city', 'state', 'country', 'postal_code', 'phone', 'fax', 'email', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['support_rep', 'invoices', 'invoice_lines', 'tracks', 'albums', 'artists', 'genres', 'media_types', 'playlist_tracks', 'playlists']
    end
  end
end
