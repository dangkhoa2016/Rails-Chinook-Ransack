class Artist < ApplicationRecord
  has_many :albums
  has_many :tracks, through: :albums
  has_many :genres, through: :tracks, source: :genre
  has_many :media_types, through: :tracks, source: :media_type
  has_many :invoice_lines, through: :tracks
  has_many :invoices, through: :invoice_lines
  has_many :customers, through: :invoices
  has_many :playlist_tracks, through: :tracks
  has_many :playlists, through: :playlist_tracks
  has_many :support_reps, through: :customers, source: :support_rep

  attr_accessor :albums_count

  validates :name, presence: true


  scope :with_albums_count_in_range, -> (min_value, max_value = nil) {
    # use the sub query from Album model
    where(id: Album.with_album_count_by_artist_in_range_for_use_as_sub_query(min_value, max_value))
  }

  scope :has_albums, -> (has_albums = true) {
    sub_query = Album.select('1').where('albums.artist_id = artists.id')
    if has_albums
      where('EXISTS (?)', sub_query)
    else
      where.not('EXISTS (?)', sub_query)
    end
  }


  def to_s
    name
  end

  def display_albums_count
    albums_count || albums.count
  end


  class << self

    def display_columns
      [
        'id',
        {
          field: 'name',
          only_in_form: true
        },
        'display_albums_count', 'created_at', 'updated_at'
      ]
    end

    def ransackable_attributes(auth_object = nil)
      ['id', 'name', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['albums', 'tracks', 'genres', 'media_types', 'invoice_lines', 'invoices', 'customers', 'playlist_tracks', 'playlists', 'support_reps']
    end

    def artist_ids_with_most_albums(has_more_than_albums = 5)
      Artist.joins(:albums).group(:artist_id).having("count_id >= #{has_more_than_albums}").order('count_id desc').count('id')
    end
    
    def first_of_artist_ids_with_most_albums(has_more_than_albums = 5)
      artist_ids_with_most_albums(has_more_than_albums)&.keys.first
    end

    def last_of_artist_ids_with_most_albums(has_more_than_albums = 5)
      artist_ids_with_most_albums(has_more_than_albums)&.keys.last
    end

    def artist_ids_with_fewest_albums(has_less_than_albums = 5)
      Artist.joins(:albums).group(:artist_id).having("count_id <= #{has_less_than_albums}").order('count_id desc').count('id')
    end

    def first_of_artist_ids_with_fewest_albums(has_more_than_albums = 5)
      artist_ids_with_fewest_albums(has_more_than_albums)&.keys.first
    end

    def last_of_artist_ids_with_fewest_albums(has_more_than_albums = 5)
      artist_ids_with_fewest_albums(has_more_than_albums)&.keys.last
    end
  end
end
