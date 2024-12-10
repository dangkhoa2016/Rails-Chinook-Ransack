# group Albums by Artist and order by count of Albums in descending order, pick only artist that has more than 5 albums
counts = Album.group('artist_id').having('count_albums_id > 5').order('count_albums_id desc').count('albums.id')
# generated sql
# SELECT COUNT("albums"."id") AS "count_albums_id", "albums"."artist_id" AS "albums_artist_id" FROM "albums" GROUP BY "albums"."artist_id" HAVING (count_albums_id > 5) ORDER BY count_albums_id desc

shared_context = Ransack::Context.for(Album)

create_at_query = Album.ransack(
  { created_at_lteq: Date.current }, context: shared_context
)

updated_at_query = Album.ransack(
  { updated_at_lteq: Date.current }, context: shared_context
)

shared_conditions = [create_at_query, updated_at_query].map { |search|
  Ransack::Visitor.new.accept(search.base)
}

Album.where(shared_conditions.reduce(&:or)) .to_sql

Album.ransack( created_at_lteq: Date.current). result. count

#----

puts Album.ransack("created_at_or_updated_at_gteq"=>"2024-12-09").result.to_sql
puts Album.ransack("created_at_or_updated_at_gteq"=>"2024-09-09", "created_at_or_updated_at_lteq"=>"2024-12-09").result.to_sql
