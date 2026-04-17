module Countable
  extend ActiveSupport::Concern

  included do
    # Generic scope to filter records by count of a related model.
    # Used as a subquery: Model.where(id: JoinModel.count_in_range(:foreign_key, min, max))
    #
    # Example:
    #   PlaylistTrack.count_in_range(:playlist, 5, 10)
    #   => SELECT playlist_id FROM playlist_tracks GROUP BY playlist_id HAVING COUNT(id) BETWEEN 5 AND 10
    scope :count_in_range, ->(model, min_value, max_value = nil) {
      return none if min_value.nil? && max_value.nil?

      column_name = "#{model.to_s.singularize}_id"
      query = select(column_name).group(column_name)

      if min_value.present? && max_value.present?
        return none if min_value > max_value

        if min_value == max_value
          query = query.having('COUNT(id) = ?', min_value)
        else
          query = query.having('COUNT(id) BETWEEN ? AND ?', min_value, max_value)
        end
      elsif min_value.nil?
        query = query.having('COUNT(id) <= ?', max_value)
      else
        query = query.having('COUNT(id) >= ?', min_value)
      end

      query
    }
  end
end
