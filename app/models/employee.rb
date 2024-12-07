class Employee < ApplicationRecord
  has_many :customers, foreign_key: 'support_rep_id'
  belongs_to :reporting_to, class_name: 'Employee', optional: true, foreign_key: 'reports_to'
  has_many :subordinates, class_name: 'Employee', foreign_key: 'reports_to'
  has_many :invoices, through: :customers
  has_many :invoice_lines, through: :invoices
  has_many :tracks, through: :invoice_lines
  has_many :genres, through: :tracks, source: :genre
  has_many :media_types, through: :tracks, source: :media_type
  has_many :playlist_tracks, through: :tracks
  has_many :playlists, through: :playlist_tracks
  has_many :albums, through: :tracks, source: :album
  has_many :artists, through: :albums

  def full_name
    [first_name, last_name].join(' ')
  end
end
