class BulkActions::Tracks::BulkDestroyController < BulkActions::BulkDestroyController

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
end
