module Sortable
  SORT_DIRECTIONS = %w[asc desc].freeze


  def sort_column
    @sort_column ||= (params[:sort].presence || 'created_at').downcase  # Default to 'created_at' if no param
  end

  def sort_direction
    @sort_direction ||= begin
      direction = params[:direction]&.downcase
      SORT_DIRECTIONS.include?(direction) ? direction : 'desc'
    end
  end

  def sort_direction_param(column)
    if is_current_sort_column?(column) && sort_direction == 'asc'
      'desc'
    else
      'asc'
    end
  end

  def is_current_sort_column?(column)
    sort_column == column.to_s.downcase
  end

  def sort_direction_asc?
    sort_direction == 'asc'
  end

  def sort_direction_desc?
    sort_direction == 'desc'
  end
end
