# group Albums by Artist and order by count of Albums in descending order, pick only artist that has more than 5 albums
counts = Album.group('artist_id').having('count_albums_id > 5').order('count_albums_id desc').count('albums.id')
# generated sql
# SELECT COUNT("albums"."id") AS "count_albums_id", "albums"."artist_id" AS "albums_artist_id" FROM "albums" GROUP BY "albums"."artist_id" HAVING (count_albums_id > 5) ORDER BY count_albums_id desc
