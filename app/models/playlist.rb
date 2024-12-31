class Playlist < ApplicationRecord
  has_many :playlist_tracks
  has_many :tracks, through: :playlist_tracks
  has_many :albums, through: :tracks, source: :album
  has_many :artists, through: :albums
  has_many :genres, through: :tracks, source: :genre
  has_many :media_types, through: :tracks, source: :media_type
  has_many :invoice_lines, through: :tracks
  has_many :invoices, through: :invoice_lines
  has_many :customers, through: :invoices
  has_many :support_reps, through: :customers

  attr_accessor :tracks_count


  scope :with_tracks_count_in_range, -> (min_value, max_value = nil) {
    # use the sub query from Track model
    # where(id: Track.with_track_count_by_playlist_in_range_for_use_as_sub_query(min_value, max_value))

    # use the sub query from PlaylistTrack model
    where(id: PlaylistTrack.with_record_count_by_model_in_range_for_use_as_sub_query(:playlist, min_value, max_value))
  }

  scope :has_tracks, -> (has_tracks = true) {
    sub_query = PlaylistTrack.select('1').where('playlist_tracks.playlist_id = playlists.id')
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
      ['playlist_tracks', 'tracks', 'albums', 'artists', 'genres', 'media_types', 'invoice_lines', 'invoices', 'customers', 'support_reps']
    end

    
    def playlist_ids_with_most_tracks(has_more_than_tracks = 5)
      PlaylistTrack.group(:playlist_id).having("count_id >= #{has_more_than_tracks}").order('count_id desc').count('id')
    end

    def first_of_playlist_ids_with_most_tracks(has_more_than_tracks = 5)
      playlist_ids_with_most_tracks(has_more_than_tracks)&.keys.first
    end

    def last_of_playlist_ids_with_most_tracks(has_more_than_tracks = 5)
      playlist_ids_with_most_tracks(has_more_than_tracks)&.keys.last
    end


    def playlist_ids_with_fewest_tracks(has_fewer_than_tracks = 5)
      PlaylistTrack.group(:playlist_id).having("count_id <= #{has_fewer_than_tracks}").order('count_id desc').count('id')
    end

    def first_of_playlist_ids_with_fewest_tracks(has_more_than_tracks = 5)
      playlist_ids_with_fewest_tracks(has_more_than_tracks)&.keys.first
    end

    def last_of_playlist_ids_with_fewest_tracks(has_more_than_tracks = 5)
      playlist_ids_with_fewest_tracks(has_more_than_tracks)&.keys.last
    end
  end
end
