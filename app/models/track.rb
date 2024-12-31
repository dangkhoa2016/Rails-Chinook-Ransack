class Track < ApplicationRecord
  belongs_to :album
  has_one :artist, through: :album
  belongs_to :media_type
  belongs_to :genre
  has_many :invoice_lines
  has_many :invoices, through: :invoice_lines
  has_many :playlist_tracks
  has_many :playlists, through: :playlist_tracks
  has_many :customers, through: :invoices
  has_many :support_reps, through: :customers

  attr_accessor :invoice_lines_count, :invoices_count, :customers_count, :artists_count,
    :support_reps_count, :playlist_tracks_count, :playlists_count


  scope :with_track_count_by_album_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    with_track_count_by_model_in_range_for_use_as_sub_query(:album, min_value, max_value)
  }

  scope :with_track_count_by_genre_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    with_track_count_by_model_in_range_for_use_as_sub_query(:genre, min_value, max_value)
  }

  scope :with_track_count_by_media_type_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    with_track_count_by_model_in_range_for_use_as_sub_query(:media_type, min_value, max_value)
  }

  scope :with_track_count_by_playlist_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    with_track_count_by_model_in_range_for_use_as_sub_query(:playlist, min_value, max_value)
  }

  scope :with_track_count_by_model_in_range_for_use_as_sub_query, ->(model, min_value, max_value = nil) {
    return {} if min_value.nil? && max_value.nil?

    query = if model.to_s.downcase == 'playlist'
      PlaylistTrack.select('playlist_id').group('playlist_id')
    else
      column_name = "#{model.to_s.singularize}_id"
      Track.select(column_name).group(column_name)
    end

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

  scope :has_invoices, ->(has_invoices = true) {
    sub_query = InvoiceLine.select('1').where('invoice_lines.track_id = tracks.id')
    if has_invoices
      where('EXISTS (?)', sub_query)
    else
      where.not('EXISTS (?)', sub_query)
    end
  }

  scope :has_composers, ->(has_composers = true) {
    if has_composers
      where.not(composer: nil)
    else
      where(composer: nil)
    end
  }


  def to_s
    name
  end

  def display_invoice_lines_count
    invoice_lines_count || invoice_lines.count
  end


  class << self

    def display_columns
      [
        'id',
        {
          field: 'album',
          type: 'association',
        },
        {
          field: 'genre',
          type: 'association',
        },
        {
          field: 'media_type',
          type: 'association',
        },
        'composer', 'milliseconds', 'bytes', 'unit_price',
        'display_invoice_lines_count',
        'created_at', 'updated_at'
      ]
    end

    def ransackable_attributes(auth_object = nil)
      ['id', 'name', 'composer', 'milliseconds', 'bytes', 'unit_price', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['album', 'media_type', 'genre', 'invoice_lines', 'invoices', 'playlist_tracks', 'playlists', 'customers', 'artists', 'support_reps']
    end

    def count_by_model_ids(model, ids)
      column_name = "#{model.to_s.singularize}_id"
      if column_names.include?(column_name)
        Track.where(column_name => ids).group(column_name).count('id')
      elsif model.to_s == 'playlist'
        PlaylistTrack.where(playlist_id: ids).group(:playlist_id).count('id')
      else
        {}
      end
    end

    def count_invoices_by_ids(track_ids)
      Track.joins(:invoices).
        group('tracks.id').
        select('tracks.id, COUNT(DISTINCT invoices.id) AS invoices_count').
        where(tracks: { id: track_ids }).
        map { |track| [track.id, track['invoices_count']] }.to_h
    end

    def count_invoice_lines_by_ids(track_ids)
      Track.joins(:invoice_lines).
        group('tracks.id').
        select('tracks.id, COUNT(DISTINCT invoice_lines.invoice_id) AS invoice_lines_count').
        where(tracks: { id: track_ids }).
        map { |track| [track.id, track['invoice_lines_count']] }.to_h
    end


    def top_tracks_with_most_orders(limit = 5)
      Track.joins(:invoice_lines).
        group('tracks.id').
        select('tracks.id, COUNT(DISTINCT invoice_lines.invoice_id) AS invoices_count').
        order('invoices_count DESC').
        limit(limit).
        map { |track| [track.id, track['invoices_count']] }.to_h
    end

    def first_of_top_tracks_with_most_orders
      top_tracks_with_most_orders(1)&.keys.first
    end

    def last_of_top_tracks_with_most_orders
      top_tracks_with_most_orders(1)&.keys.last
    end


    def top_tracks_with_fewest_orders(limit = 5)
      Track.joins(:invoice_lines).
        group('tracks.id').
        select('tracks.id, COUNT(DISTINCT invoice_lines.invoice_id) AS invoices_count').
        order('invoices_count ASC').
        limit(limit).
        map { |track| [track.id, track['invoices_count']] }.to_h
    end

    def first_of_top_tracks_with_fewest_orders
      top_tracks_with_fewest_orders(1)&.keys.first
    end

    def last_of_top_tracks_with_fewest_orders
      top_tracks_with_fewest_orders(1)&.keys.last
    end


    def top_tracks_with_longest_duration(limit = 5)
      Track.order(milliseconds: :desc).limit(limit).pluck(:id, :milliseconds).to_h
    end

    def first_of_top_tracks_with_longest_duration
      top_tracks_with_longest_duration(1)&.keys.first
    end

    def last_of_top_tracks_with_longest_duration
      top_tracks_with_longest_duration(1)&.keys.last
    end


    def top_tracks_with_shortest_duration(limit = 5)
      Track.order(milliseconds: :asc).limit(limit).pluck(:id, :milliseconds).to_h
    end

    def first_of_top_tracks_with_shortest_duration
      top_tracks_with_shortest_duration(1)&.keys.first
    end

    def last_of_top_tracks_with_shortest_duration
      top_tracks_with_shortest_duration(1)&.keys.last
    end


    def top_tracks_with_most_bytes(limit = 5)
      Track.order(bytes: :desc).limit(limit).pluck(:id, :bytes).to_h
    end

    def first_of_top_tracks_with_most_bytes
      top_tracks_with_most_bytes(1)&.keys.first
    end

    def last_of_top_tracks_with_most_bytes
      top_tracks_with_most_bytes(1)&.keys.last
    end


    def top_tracks_with_fewest_bytes(limit = 5)
      Track.order(bytes: :asc).limit(limit).pluck(:id, :bytes).to_h
    end
    
    def first_of_top_tracks_with_fewest_bytes
      top_tracks_with_fewest_bytes(1)&.keys.first
    end
    
    def last_of_top_tracks_with_fewest_bytes
      top_tracks_with_fewest_bytes(1)&.keys.last
    end

  
    [:album, :genre, :media_type].each do |model|
      define_method("top_#{model}_ids_with_most_tracks") do |has_more_than_tracks = 5|
        Track.group("#{model}_id").having('count_id >= ?', has_more_than_tracks).count('id')
      end

      define_method("first_of_top_#{model}_ids_with_most_tracks") do |has_more_than_tracks = 5|
        send("top_#{model}_ids_with_most_tracks", has_more_than_tracks)&.keys.first
      end

      define_method("last_of_top_#{model}_ids_with_most_tracks") do |has_more_than_tracks = 5|
        send("top_#{model}_ids_with_most_tracks", has_more_than_tracks)&.keys.last
      end

  
      define_method("top_#{model}_ids_with_fewest_tracks") do |has_less_than_tracks = 5|
        Track.group("#{model}_id").having('count_id <= ?', has_less_than_tracks).count('id')
      end

      define_method("first_of_top_#{model}_ids_with_fewest_tracks") do |has_less_than_tracks = 5|
        send("top_#{model}_ids_with_fewest_tracks", has_less_than_tracks)&.keys.first
      end

      define_method("last_of_fewest_tracks_by_#{model}") do |has_less_than_tracks = 5|
        send("top_#{model}_ids_with_fewest_tracks", has_less_than_tracks)&.keys.last
      end
    end
  end
end
