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

  attr_accessor :tracks_count

  scope :with_tracks_count_in_range_1, -> (min_value, max_value = nil) {
    # Create a sub query to get the albums with track count in the specified range
    sub_query = Album.joins(:tracks)
                    .select('albums.id').group('albums.id')
                    .having('COUNT(tracks.id) >= ? AND COUNT(tracks.id) <= ?', min_value, max_value)

    # Use the sub query in the main query
    where(id: sub_query)
  }

  scope :with_tracks_count_in_range, -> (min_value, max_value = nil) {
    # use the sub query from Track model
    where(id: Track.with_track_count_by_album_in_range_for_use_as_sub_query(min_value, max_value))
  }

  scope :created_or_updated_within, ->(start_date, end_date) {
    where('(created_at BETWEEN :start_date AND :end_date) OR (updated_at BETWEEN :start_date AND :end_date)',
      start_date: start_date, end_date: end_date)
  }

  scope :has_tracks, -> (has_tracks = true) {
    sub_query = Track.select('1').where('tracks.album_id = albums.id')
    if has_tracks
      where('EXISTS (?)', sub_query)
    else
      where.not('EXISTS (?)', sub_query)
    end
  }

  scope :with_album_count_by_artist_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    return {} if min_value.nil? && max_value.nil?

    column_name = 'artist_id'
    query = Album.select(column_name).group(column_name)

    if min_value.present? && max_value.present?
      if min_value > max_value
        return {}
      elsif min_value == max_value
        query = query.having('COUNT(id) = ?', min_value)
      else
        query = query.having('COUNT(id) BETWEEN ? AND ?', min_value, max_value)
      end
    elsif min_value.nil? && max_value.present?
      query = query.having('COUNT(id) <= ?', max_value)
    elsif min_value.present? && max_value.nil?
      query = query.having('COUNT(id) >= ?', min_value)
    end

    query
  }


  class << self
    def ransackable_attributes(auth_object = nil)
      ['id', 'title', 'artist_id', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['artist', 'tracks', 'genres', 'media_types', 'invoice_lines', 'invoices', 'customers', 'playlist_tracks', 'playlists', 'support_reps']
    end

    def count_by_artist_ids(ids)
      column_name = 'artist_id'
      if column_names.include?(column_name)
        Album.where(column_name => ids).group(column_name).count('id')
      else
        {}
      end
    end

    def artist_ids_with_most_albums(has_more_than_albums = 5)
      Album.group(:artist_id).having("count_id >= #{has_more_than_albums}").order('count_id desc').count('id')
    end

    def first_of_artist_ids_with_most_albums(has_more_than_albums = 5)
      artist_ids_with_most_albums(has_more_than_albums)&.keys.first
    end

    def last_of_artist_ids_with_most_albums(has_more_than_albums = 5)
      artist_ids_with_most_albums(has_more_than_albums)&.keys.last
    end

    def artist_ids_with_fewest_albums(has_less_than_albums = 5)
      Album.group(:artist_id).having("count_id <= #{has_less_than_albums}").order('count_id desc').count('id')
    end

    def first_of_artist_ids_with_fewest_albums(has_more_than_albums = 5)
      artist_ids_with_fewest_albums(has_more_than_albums)&.keys.first
    end

    def last_of_artist_ids_with_fewest_albums(has_more_than_albums = 5)
      artist_ids_with_fewest_albums(has_more_than_albums)&.keys.last
    end


    def album_ids_with_most_tracks(has_more_than_tracks = 5)
      Album.joins(:tracks).group('albums.id').having("count_tracks_id >= #{has_more_than_tracks}").order('count_tracks_id desc').count('tracks.id')
    end

    def first_of_album_ids_with_most_tracks(has_more_than_tracks = 5)
      album_ids_with_most_tracks(has_more_than_tracks)&.keys.first
    end

    def last_of_album_ids_with_most_tracks(has_more_than_tracks = 5)
      album_ids_with_most_tracks(has_more_than_tracks)&.keys.last
    end

    def album_ids_with_fewest_tracks(has_less_than_tracks = 5)
      Album.joins(:tracks).group('albums.id').having("count_tracks_id <= #{has_less_than_tracks}").order('count_tracks_id desc').count('tracks.id')
    end

    def first_of_album_ids_with_fewest_tracks(has_less_than_tracks = 5)
      album_ids_with_fewest_tracks(has_less_than_tracks)&.keys.first
    end

    def last_of_album_ids_with_fewest_tracks(has_less_than_tracks = 5)
      album_ids_with_fewest_tracks(has_less_than_tracks)&.keys.last
    end
  end
end
