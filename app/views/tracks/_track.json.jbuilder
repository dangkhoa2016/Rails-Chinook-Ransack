json.extract! track, :id, :name, :album_id, :media_type_id, :genre_id, :composer, :milliseconds, :bytes, :unit_price, :created_at, :updated_at
json.url track_url(track, format: :json)
