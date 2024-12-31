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

  scope :with_record_count_by_track_in_range_for_use_as_sub_query, ->(min_value, max_value) {
    with_record_count_by_model_in_range_for_use_as_sub_query(:track, min_value, max_value)
  }

  scope :with_record_count_by_invoice_in_range_for_use_as_sub_query, ->(min_value, max_value) {
    with_record_count_by_model_in_range_for_use_as_sub_query(:invoice, min_value, max_value)
  }
  
  scope :with_record_count_by_model_in_range_for_use_as_sub_query, ->(model, min_value, max_value = nil) {
    return InvoiceLine.none if min_value.nil? && max_value.nil?

    column_name = "#{model.to_s.singularize}_id"
    query = InvoiceLine.select(column_name).group(column_name)

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

  scope :by_customer_ids, ->(ids) {
    where(invoice_id: Invoice.where(customer_id: ids).select(:id))
  }

  scope :by_customer_name, ->(name) {
    # where(invoice_id: Invoice.where(customer_id: Customer.where('first_name ILIKE ? OR last_name ILIKE ?', "%#{name}%", "%#{name}%").select(:id)).select(:id))
    joins(:customer)
    .ransack(customer_first_name_or_last_name_cont: name)
    .result
  }


  def total_price
    unit_price * quantity
  end

  def to_s
    "#{self.class.human_attribute_name('id')}: #{id}"
  end


  class << self

    def display_columns
      [
        'id',
        {
          field: 'invoice',
          type: 'association',
        },
        {
          field: 'track',
          type: 'association',
        },
        'unit_price', 'quantity', 'total_price',
        'created_at', 'updated_at'
      ]
    end

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
