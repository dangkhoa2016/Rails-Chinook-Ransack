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
        { name: 'artist_ids_eq', type: 'select_field', label: 'Most popular artists', collection: lambda { load_most_popular_artists(10) } },
        { name: 'artist_id_eq', type: 'select_field', label: 'Belong to artist', collection: lambda {  } }
      ]
    end
  end
end
