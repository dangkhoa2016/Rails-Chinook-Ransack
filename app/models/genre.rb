class Genre < ApplicationRecord
  has_many :tracks
  has_many :albums, through: :tracks, source: :album
  has_many :artists, through: :albums
  has_many :media_types, through: :tracks, source: :media_type
  has_many :invoice_lines, through: :tracks
  has_many :invoices, through: :invoice_lines
  has_many :customers, through: :invoices
  has_many :playlist_tracks, through: :tracks
  has_many :playlists, through: :playlist_tracks
  has_many :support_reps, through: :customers, source: :support_rep

  attr_accessor :tracks_count


  scope :with_tracks_count_in_range, -> (min_value, max_value = nil) {
    # use the sub query from Track model
    where(id: Track.with_track_count_by_genre_in_range_for_use_as_sub_query(min_value, max_value))
  }

  scope :has_tracks, -> (has_tracks = true) {
    sub_query = Track.select('1').where('tracks.genre_id = genres.id')
    if has_tracks
      where('EXISTS (?)', sub_query)
    else
      where.not('EXISTS (?)', sub_query)
    end
  }


  def to_s
    name
  end

  def display_tracks_count
    tracks_count || tracks.count
  end


  class << self

    def display_columns
      [
        'id',
        'display_tracks_count', 'created_at', 'updated_at'
      ]
    end

    def ransackable_attributes(auth_object = nil)
      ['id', 'name', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['tracks', 'albums', 'artists', 'media_types', 'invoice_lines', 'invoices', 'customers', 'playlist_tracks', 'playlists', 'support_reps']
    end

    def genre_ids_with_most_tracks(has_more_than_tracks = 5)
      Track.group(:genre_id).having("count_id >= #{has_more_than_tracks}").order('count_id desc').count('id')
    end

    def first_of_genre_ids_with_most_tracks(has_more_than_tracks = 5)
      genre_ids_with_most_tracks(has_more_than_tracks)&.keys.first
    end

    def last_of_genre_ids_with_most_tracks(has_more_than_tracks = 5)
      genre_ids_with_most_tracks(has_more_than_tracks)&.keys.last
    end

    def genre_ids_with_fewest_tracks(has_fewer_than_tracks = 5)
      Track.group(:genre_id).having("count_id <= #{has_fewer_than_tracks}").order('count_id desc').count('id')
    end

    def first_of_genre_ids_with_fewest_tracks(has_more_than_tracks = 5)
      genre_ids_with_fewest_tracks(has_more_than_tracks)&.keys.first
    end

    def last_of_genre_ids_with_fewest_tracks(has_more_than_tracks = 5)
      genre_ids_with_fewest_tracks(has_more_than_tracks)&.keys.last
    end
  end
end
