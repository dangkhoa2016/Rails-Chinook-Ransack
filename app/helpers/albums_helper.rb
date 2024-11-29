module AlbumsHelper
  def search_fields
    [
      { name: 'title', type: 'text_field', label: 'Album title' },
      { name: 'artist_name', type: 'text_field', label: 'Artist name' },
      { name: 'created_at_gteq', type: 'date_field', label: 'Created at after' },
      { name: 'created_at_lteq', type: 'date_field', label: 'Created at before' },
      { name: 'created_at', type: 'range_date_field', label: 'Created at between' },
      { name: 'updated_at_gteq', type: 'date_field', label: 'Updated at after' },
      { name: 'updated_at_lteq', type: 'date_field', label: 'Updated at before' },
      { name: 'updated_at', type: 'range_date_field', label: 'Updated at between' },
      { name: 'artist_id_eq', type: 'select_field', label: 'Most popular artists', collection: lambda { load_most_popular_artists(10) } }
    ]
  end

  def search_fields_for_select
    search_fields.map { |field| [field[:label], field[:name]] }
  end

  def load_most_popular_artists(has_more_than_albums = 5)
    ids = Album.top_most_popular_artist_ids(has_more_than_albums)
    Artist.where(id: ids)
  end
end
