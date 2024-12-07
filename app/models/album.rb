class Album < ApplicationRecord
  belongs_to :artist
  has_many :tracks
  has_many :genres, through: :tracks, source: :genre
  has_many :media_types, through: :tracks, source: :media_type
  has_many :invoice_lines, through: :tracks
  has_many :invoices, through: :invoice_lines
  has_many :customers, through: :invoices
  has_many :playlist_tracks, through: :tracks
  has_many :playlists, through: :playlist_tracks
  has_many :support_reps, through: :customers, source: :support_rep

  class << self
    def ransackable_attributes(auth_object = nil)
      ['id', 'title', 'artist_id', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['artist', 'tracks', 'genres', 'media_types', 'invoice_lines', 'invoices', 'customers', 'playlist_tracks', 'playlists', 'support_reps']
    end

    def top_most_popular_artist_ids(has_more_than_albums = 5)
      Album.group('artist_id').having("count_id >= #{has_more_than_albums}").order('count_id desc').count('id')&.keys
    end

    def first_of_most_popular_artist_id(has_more_than_albums = 5)
      top_most_popular_artist_ids(has_more_than_albums).first
    end

    def last_of_most_popular_artist_id(has_more_than_albums = 5)
      top_most_popular_artist_ids(has_more_than_albums).last
    end

    def least_most_popular_artist_ids(has_less_than_albums = 5)
      Album.group('artist_id').having("count_id <= #{has_less_than_albums}").order('count_id desc').count('id')&.keys
    end

    def first_of_least_popular_artist_id(has_more_than_albums = 5)
      least_most_popular_artist_ids(has_more_than_albums).first
    end

    def last_of_least_popular_artist_id(has_more_than_albums = 5)
      least_most_popular_artist_ids(has_more_than_albums).last
    end
  end
end
