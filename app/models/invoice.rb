class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :invoice_lines
  has_many :tracks, through: :invoice_lines
  has_many :playlist_tracks, through: :tracks
  has_many :playlists, through: :playlist_tracks
  has_many :genres, through: :tracks, source: :genre
  has_many :media_types, through: :tracks, source: :media_type
  has_many :albums, through: :tracks, source: :album
  has_many :artists, through: :albums
  has_one :support_rep, through: :customer

  attr_accessor :invoice_lines_count


  scope :with_record_count_by_customer_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    return Invoice.none if min_value.nil? && max_value.nil?

    query = Invoice.select(:customer_id).group(:customer_id)

    if min_value.present? && max_value.present?
      if min_value > max_value
        return Invoice.none
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

  scope :with_invoice_lines_count_in_range, -> (min_value, max_value = nil) {
    # use the sub query from InvoiceLine model
    query = InvoiceLine.with_record_count_by_invoice_in_range_for_use_as_sub_query(min_value, max_value)
    if query.exists?
      where(id: query)
    else
      Invoice.none
    end
  }


  def total_price
    invoice_lines.pluck(:unit_price).sum
  end


  class << self
    def ransackable_attributes(auth_object = nil)
      ['id', 'customer_id', 'invoice_date', 'billing_address', 'billing_city', 'billing_state', 'billing_country', 'billing_postal_code', 'total', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['customer', 'invoice_lines', 'tracks', 'playlist_tracks', 'playlists', 'genres', 'media_types', 'albums', 'artists', 'support_rep']
    end
    
    def count_by_model_ids(model, ids)
      column_name = "#{model.to_s.singularize}_id"
      if column_names.include?(column_name)
        Invoice.where(column_name => ids).group(column_name).count
      else
        {}
      end
    end

    def count_tracks_by_invoice_ids(invoice_ids)
      Invoice.joins(invoice_lines: :track).where(id: invoice_ids).group('invoices.id').count
    end

    def customers_ids_with_most_invoices(has_more_than_invoices_or_equal_to = 7)
      Invoice.group(:customer_id).having("count_id >= #{has_more_than_invoices_or_equal_to}").order('count_id desc').count('id')
    end

    def first_of_most_invoiced_customer_id(has_more_than_invoices_or_equal_to = 7)
      customers_ids_with_most_invoices(has_more_than_invoices_or_equal_to)&.keys.first
    end

    def last_of_most_invoiced_customer_id(has_more_than_invoices_or_equal_to = 7)
      customers_ids_with_most_invoices(has_more_than_invoices_or_equal_to)&.keys.last
    end


    def customers_ids_with_fewest_invoices(has_less_than_invoices_or_equal_to = 5)
      Invoice.group(:customer_id).having("count_id <= #{has_less_than_invoices_or_equal_to}").order('count_id desc').count('id')
    end

    def first_of_fewest_invoiced_customer_id(has_less_than_invoices_or_equal_to = 5)
      customers_ids_with_fewest_invoices(has_less_than_invoices_or_equal_to)&.keys.first
    end

    def last_of_fewest_invoiced_customer_id(has_less_than_invoices_or_equal_to = 5)
      customers_ids_with_fewest_invoices(has_less_than_invoices_or_equal_to)&.keys.last
    end


    def invoice_ids_with_most_tracks(has_more_than_tracks_or_equal_to = 5)
      Invoice.joins(:invoice_lines).group('invoices.id').
        having("count_invoice_lines_id >= #{has_more_than_tracks_or_equal_to}").
        order('count_invoice_lines_id desc').
        count('invoice_lines.id')
    end

    def first_of_most_tracks_invoice_id(has_more_than_tracks_or_equal_to = 5)
      invoice_ids_with_most_tracks(has_more_than_tracks_or_equal_to)&.keys.first
    end

    def last_of_most_tracks_invoice_id(has_more_than_tracks_or_equal_to = 5)
      invoice_ids_with_most_tracks(has_more_than_tracks_or_equal_to)&.keys.last
    end


    def invoice_ids_with_fewest_tracks(has_less_than_tracks_or_equal_to = 5)
      Invoice.joins(:invoice_lines).group('invoices.id').
        having("count_invoice_lines_id <= #{has_less_than_tracks_or_equal_to}").
        order('count_invoice_lines_id desc').
        count('invoice_lines.id')
    end

    def first_of_fewest_tracks_invoice_id(has_less_than_tracks_or_equal_to = 5)
      invoice_ids_with_fewest_tracks(has_less_than_tracks_or_equal_to)&.keys.first
    end

    def last_of_fewest_tracks_invoice_id(has_less_than_tracks_or_equal_to = 5)
      invoice_ids_with_fewest_tracks(has_less_than_tracks_or_equal_to)&.keys.last
    end


    def top_most_expensive_invoice_ids(limit = 5)
      Invoice.joins(:invoice_lines).
        group('invoices.id').
        order('sum_unit_price DESC').
        limit(limit).sum('unit_price')
    end

    def first_of_top_most_expensive_invoice_ids(limit = 5)
      top_most_expensive_invoice_ids(limit)&.keys.first
    end

    def last_of_top_most_expensive_invoice_ids(limit = 5)
      top_most_expensive_invoice_ids(limit)&.keys.last
    end


    def top_fewest_expensive_invoice_ids(limit = 5)
      Invoice.joins(:invoice_lines).
        group('invoices.id').
        order('sum_unit_price ASC').
        limit(limit).sum('unit_price')
    end

    def first_of_top_fewest_expensive_invoice_ids(limit = 5)
      top_fewest_expensive_invoice_ids(limit)&.keys.first
    end

    def last_of_top_fewest_expensive_invoice_ids(limit = 5)
      top_fewest_expensive_invoice_ids(limit)&.keys.last
    end


    def invoices_ids_with_number_of_invoice_lines_between(min_value, max_value = nil)
      return {} if min_value.nil? && max_value.nil?

      query = Invoice.joins(:invoice_lines).group('invoices.id')

      if min_value.present? && max_value.present?
        if min_value > max_value
          return {}
        elsif min_value == max_value
          query = query.having('count_invoice_lines_id = ?', min_value)
        else
          query = query.having('count_invoice_lines_id BETWEEN ? AND ?', min_value, max_value)
        end
      elsif min_value.nil? && max_value.present?
        query = query.having('count_invoice_lines_id <= ?', max_value)
      elsif min_value.present? && max_value.nil?
        query = query.having('count_invoice_lines_id >= ?', min_value)
      end

      query.count('invoice_lines.id')
    end


    def invoices_ids_with_total_price_between(min_value, max_value = nil)
      return {} if min_value.nil? && max_value.nil?

      query = Invoice.joins(:invoice_lines).group('invoices.id')

      if min_value.present? && max_value.present?
        if min_value > max_value
          return {}
        elsif min_value == max_value
          query = query.having('sum_unit_price = ?', min_value)
        else
          query = query.having('sum_unit_price BETWEEN ? AND ?', min_value, max_value)
        end
      elsif min_value.nil? && max_value.present?
        query = query.having('sum_unit_price <= ?', max_value)
      elsif min_value.present? && max_value.nil?
        query = query.having('sum_unit_price >= ?', min_value)
      end

      query.sum('unit_price')
    end
  end
end
