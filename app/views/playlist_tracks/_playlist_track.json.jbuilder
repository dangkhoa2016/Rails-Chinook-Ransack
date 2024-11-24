json.extract! playlist_track, :id, :playlist_id, :track_id, :created_at, :updated_at
json.url playlist_track_url(playlist_track, format: :json)
