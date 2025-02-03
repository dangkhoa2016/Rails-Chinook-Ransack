class BulkActions::Albums::BulkEditController < BulkActions::BulkEditController
  
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

  private

  def editable_fields
    %w[title artist created_at updated_at]
  end
  
  def bulk_edit_params
    params.require(:album).permit(:title, :artist_id, :created_at, :updated_at).to_h
  end
end
