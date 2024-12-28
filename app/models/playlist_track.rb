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


  scope :with_record_count_by_model_in_range_for_use_as_sub_query, ->(model, min_value, max_value = nil) {
    return PlaylistTrack.none if min_value.nil? && max_value.nil?

    column_name = "#{model.to_s.singularize}_id"
    query = PlaylistTrack.select(column_name).group(column_name)

    if min_value.present? && max_value.present?
      if min_value > max_value
        return PlaylistTrack.none
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
      ['id', 'playlist_id', 'track_id', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['playlist', 'track', 'genre', 'media_type', 'album', 'artist', 'invoice_lines', 'invoices', 'customers', 'support_reps']
    end
    
    def count_by_model_ids(model, ids)
      column_name = "#{model.to_s.singularize}_id"
      if column_names.include?(column_name)
        PlaylistTrack.where(column_name => ids).group(column_name).count('id')
      else
        {}
      end
    end
  end
end
