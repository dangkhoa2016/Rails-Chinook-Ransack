class Track < ApplicationRecord
  belongs_to :album
  has_one :artist, through: :album
  belongs_to :media_type
  belongs_to :genre
  has_many :invoice_lines
  has_many :invoices, through: :invoice_lines
  has_many :playlist_tracks
  has_many :playlists, through: :playlist_tracks
  has_many :customers, through: :invoices
  has_many :support_reps, through: :customers


  scope :with_track_count_by_album_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    with_track_count_by_model_in_range_for_use_as_sub_query(:album, min_value, max_value)
  }

  scope :with_track_count_by_genre_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    with_track_count_by_model_in_range_for_use_as_sub_query(:genre, min_value, max_value)
  }

  scope :with_track_count_by_media_type_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    with_track_count_by_model_in_range_for_use_as_sub_query(:media_type, min_value, max_value)
  }

  scope :with_track_count_by_model_in_range_for_use_as_sub_query, ->(model, min_value, max_value = nil) {
    return {} if min_value.nil? && max_value.nil?

    column_name = "#{model.to_s.singularize}_id"
    query = Track.select(column_name).group(column_name)

    if min_value.present? && max_value.present?
      if min_value > max_value
        return {}
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
      ['id', 'name', 'composer', 'milliseconds', 'bytes', 'unit_price', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['album', 'media_type', 'genre', 'invoice_lines', 'invoices', 'playlist_tracks', 'playlists', 'customers', 'artists', 'support_reps']
    end

    def count_by_model_ids(model, ids)
      column_name = "#{model.to_s.singularize}_id"
      if column_names.include?(column_name)
        Track.where(column_name => ids).group(column_name).count
      else
        {}
      end
    end
  end
end
