class BulkActions::Albums::BulkDestroyController < BulkActions::BulkDestroyController
  
  def model_query
    query = model.includes(:artist)
    if is_sort_by_tracks_count?
      query = query.left_joins(:tracks).group('albums.id')
    end

    query
  end

  def model
    Album
  end

  def is_sort_by_tracks_count?
    @is_sort_by_tracks_count ||= (sort_column == 'tracks_count')
  end

end
