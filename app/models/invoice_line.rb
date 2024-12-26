class InvoiceLine < ApplicationRecord
  belongs_to :invoice
  belongs_to :track
  has_one :customer, through: :invoice
  has_one :support_rep, through: :customer
  has_one :album, through: :track
  has_one :artist, through: :album
  has_one :genre, through: :track
  has_one :media_type, through: :track
  has_many :playlist_tracks, through: :track
  has_many :playlists, through: :playlist_tracks
  

  scope :with_record_count_by_invoice_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    return InvoiceLine.none if min_value.nil? && max_value.nil?

    column_name = "#{model.to_s.singularize}_id"
    query = InvoiceLine.select(:invoice_id).group(:invoice_id)

    if min_value.present? && max_value.present?
      if min_value > max_value
        return InvoiceLine.none
      elsif min_value == max_value
        query = query.having('COUNT(id) = ?', min_value)
      else
        query = query.having('COUNT(id) BETWEEN ? AND ?', min_value, max_value)
      end
    elsif min_value.nil? && max_value.present?
      query = query.having('COUNT(id) <= ?', max_value)
    elsif min_value.present? && max_value.nil?
      query = query.having('COUNT(id) >= ?', min_value)
    end

    query
  }


  class << self
    def ransackable_attributes(auth_object = nil)
      ['id', 'invoice_id', 'track_id', 'unit_price', 'quantity', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['invoice', 'track', 'customer', 'support_rep', 'album', 'artist', 'genre', 'media_type', 'playlist_tracks', 'playlists']
    end

    def count_by_model_ids(model, ids)
      column_name = "#{model.to_s.singularize}_id"
      if column_names.include?(column_name)
        InvoiceLine.where(column_name => ids).group(column_name).count
      else
        {}
      end
    end
  end
end
