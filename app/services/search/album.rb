module Search
  class Album < Search::Base

    class << self
      def search_fields
        [
          [
            get_translate_key('model_fields'),
            [
              {
                name: 'ids', type: 'remote_select_field',
                ransack_field_name: 'id_in',
                label: get_translate_key('ids'),
                props: lambda do |helper|
                  {
                    placeholder: get_translate_key('select_albums'),
                    filter_url: helper.get_index_url_for_model(:album, format: :json),
                  }
                end
              },
              {
                name: 'title', type: 'text_field',
                ransack_field_name: 'title_cont',
                label: get_translate_key('title')
              },
              {
                name: 'album_or_artist_contains', type: 'text_field',
                ransack_field_name: 'title_or_artist_name_cont',
                label: get_translate_key('album_or_artist_contains')
              },
              {
                name: 'number_of_tracks_between', type: 'range_number_field',
                scope_name: 'with_tracks_count_in_range',
                fiter_label: get_translate_key('number_of_tracks'),
                label: get_translate_key('number_of_tracks_between')
              },
              {
                name: 'has_tracks', type: 'boolean_field',
                scope_name: 'has_tracks',
                label: get_translate_key('has_tracks')
              },
            ]
          ],
          [
            get_translate_key('artist_fields'),
            [
              {
                name: 'artist_name', type: 'text_field',
                ransack_field_name: 'artist_name_cont',
                label: get_translate_key('artist_name')
              },
              {
                name: 'artist_ids', type: 'remote_select_field',
                ransack_field_name: 'artist_id_in',
                label: get_translate_key('belong_to_artists'),
                props: lambda do |helper|
                  props_lambda = lambda do |helper|
                    {
                      placeholder: get_translate_key('select_artists'),
                      filter_url: helper.get_index_url_for_model(:artist, format: :json),
                    }
                  end

                  props_lambda
                end
              },
            ]
          ],
          
          base_timestamp_fields
        ]
      end

      def filter_templates
        [
          # test filter templates
          {
            name: 'by_artist_name_accept',
            label: get_translate_key('template.by_artist_name_accept_test'),
            filters: [
              {
                name: 'artist_name',
                value: 'Accept'
              }
            ]
          },
          {
            name: 'by_artist_name_accept_and_created_at_this_year', # artist name is Accept and created at this year
            label: get_translate_key('template.by_artist_name_accept_and_created_at_this_year_test'),
            filters: lambda do |helper|
              [
                from_search_field('artist_name', 'Accept', helper),
                from_template('created_at_this_year', helper)
              ].flatten.compact
            end
          },
          {
            name: 'by_artist_pearl_jam', # Pearl Jam
            label: get_translate_key('template.by_artist_pearl_jam_test'),
            filters: lambda do |helper|
              [from_search_field('artist_ids', get_collection_by_model_ids(:artist, [118]), helper)]
            end
          },
          # test filter templates

          {
            name: 'artists_who_have_10_or_more_albums',
            label: get_translate_key('template.artists_who_have_10_or_more_albums'),
            filters: lambda do |helper|
              [
                from_search_field('artist_ids', load_artists_by_number_albums(10, true), helper)
              ]
            end
          },
          {
            name: 'artists_who_have_2_or_fewer_albums',
            label: get_translate_key('template.artists_who_have_2_or_fewer_albums'),
            filters: lambda do |helper|
              [
                from_search_field('artist_ids', load_artists_by_number_albums(2, false), helper)
              ]
            end
          },
          {
            name: 'albums_that_have_25_or_more_tracks',
            label: get_translate_key('template.albums_that_have_25_or_more_tracks'),
            filters: lambda do |helper|
              [
                from_search_field('ids', load_album_by_number_tracks(25, true), helper)
              ]
            end
          },
          {
            name: 'albums_that_have_2_or_fewer_tracks',
            label: get_translate_key('template.albums_that_have_2_or_fewer_tracks'),
            filters: lambda do |helper|
              [
                from_search_field('ids', load_album_by_number_tracks(2, false), helper)
              ]
            end
          },
          {
            name: 'albums_with_no_tracks',
            label: get_translate_key('template.albums_with_no_tracks'),
            filters: [
              {
                name: 'has_tracks',
                value: false
              }
            ]
          }
        ] + base_template_fields
      end

      def model
        'Album'
      end

      def load_artists_by_number_albums(num = 10, is_top = true)
        if is_top
          ids = ::Album.artist_ids_with_most_albums(num)
        else
          ids = ::Album.artist_ids_with_fewest_albums(num)
        end

        result = get_collection_by_model_ids(:artist, ids.keys)
        result.each do |record|
          total_albums = ids.find { |id, _| id == record.last }&.last
          record[0] = "#{record[0]} - #{pluralize(total_albums, 'album')}"
        end

        result
      end

      def load_album_by_number_tracks(num = 10, is_top = true)
        if is_top
          ids = ::Album.album_ids_with_most_tracks(num)
        else
          ids = ::Album.album_ids_with_fewest_tracks(num)
        end

        result = get_collection_by_model_ids(:album, ids.keys)
        result.each do |record|
          total_tracks = ids.find { |id, _| id == record.last }&.last
          record[0] = "#{record[0]} - #{pluralize(total_tracks, 'track')}"
        end

        result
      end
    end
  end
end
