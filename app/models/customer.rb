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

  attr_accessor :invoices_count

  scope :with_invoices_count_in_range, -> (min_value, max_value = nil) {
    # use the sub query from Invoice model
    query = Invoice.with_record_count_by_customer_in_range_for_use_as_sub_query(min_value, max_value)
    if query.exists?
      where(id: query)
    else
      none
    end
  }

  scope :has_invoices, -> (has_invoices = true) {
    sub_query = Invoice.select('1').where('invoices.customer_id = customers.id')
    if has_invoices
      where('EXISTS (?)', sub_query)
    else
      where.not('EXISTS (?)', sub_query)
    end
  }


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
