module AlbumsHelper
  def search_fields_for_select
    Album.search_fields.map { |field| [field[:label], field[:name]] }
  end

  def load_most_popular_artists(has_more_than_albums = 5)
    ids = Album.top_most_popular_artist_ids(has_more_than_albums)
    Artist.where(id: ids)
  end
end
