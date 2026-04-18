class BulkActions::Artists::BulkEditController < BulkActions::BulkEditController

  def model_query
    if is_sort_by_albums_count?
      Artist.left_joins(:albums).group('artists.id')
    else
      Artist.includes(:albums)
    end
  end

  def model
    Artist
  end

  def is_sort_by_albums_count?
    @is_sort_by_albums_count ||= (sort_column == 'albums_count')
  end

  private

  def editable_fields
    %w[name created_at updated_at]
  end
end
