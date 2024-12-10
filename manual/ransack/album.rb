# find the album that has shortest title
album = Album.order('LENGTH(title)').first
# find the album that has longest title
album = Album.order('LENGTH(title) DESC').first
# find the album that has the most tracks
album = Album.joins(:tracks).group('albums.id').order('COUNT(tracks.id) DESC').first
album.tracks. count
# find the album that has the fewest tracks
album = Album.joins(:tracks).group('albums.id').order('COUNT(tracks.id)').first
album.tracks. count
# find the album that has the most genres
album = Album.joins(:genres).group('albums.id').distinct('genres.id').order('COUNT(genres.id) DESC').first
album.genres.distinct.count
Track.where(album_id: 141).includes(:genre).distinct('genres.id').count('genres.id')
Track.where(album_id: 141).includes(:genre).distinct('genres.name').pluck('genres.name, genres.id')
Genre.where(id: Track.where(album_id: 141).select('genre_id').distinct).count

# find the album that has the fewest genres
album = Album.joins(:genres).group('albums.id').distinct('genres.id').order('COUNT(genres.id)').first
album.genres.distinct.count

# ransack search
# find the albums that has title 'IV'
albums = Album.ransack(title_eq: 'IV')
# find the albums that contains 'John' in the title
albums = Album.ransack(title_cont: 'John').result
# find the albums that is belong to artist with name 'John'
albums = Album.ransack(artist_name_eq: 'John').result
# find the albums that is belong to artist with name contains 'John'
albums = Album.ransack(artist_name_cont: 'John').result
# find the albums that is belong to artist with name contains 'John' and title contains 'IV'
albums = Album.ransack(artist_name_cont: 'John', title_cont: 'Requiem').result
# find the albums that has tracks with composer contains 'Philip'
albums = Album.ransack(tracks_composer_cont: 'Philip').result


# update random albums created_at
Album.order('RANDOM()').limit(100).each do |album|
  album.update_column(:created_at, Time.now.since(rand(-100 * 86400..100 * 86400).seconds))
end

# find albums that has created_at is greater than updated_at
albums = Album.where('created_at > updated_at')
# update random albums updated_at
albums.each do |album|
  album.update_column(:updated_at, album.created_at.since(rand(100 * 86400).seconds))
end

# find Albums that have title containing 'ac' or artist name containing 'ac'
Album.ransack(title_or_artist_name_cont: 'ac').result.count
