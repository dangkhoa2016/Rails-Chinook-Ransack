class BulkActions::Tracks::BulkEditController < BulkActions::BulkEditController

  def model_query
    query = model.includes(:album, :media_type, :genre)
    if is_sort_by_invoice_lines_count?
      query = query.left_joins(:invoice_lines).group('tracks.id')
    end

    query
  end

  def is_sort_by_invoice_lines_count?
    @is_sort_by_invoice_lines_count ||= (sort_column == 'invoice_lines_count')
  end

  def model
    Track
  end

  private

  def editable_fields
    %w[created_at updated_at name album media_type genre composer milliseconds bytes unit_price]
  end
  
  def bulk_edit_params
    params.require(:track).permit(:created_at, :updated_at,
      :name, :album_id, :media_type_id, :genre_id,
      :composer, :milliseconds, :bytes, :unit_price).to_h
  end
end
