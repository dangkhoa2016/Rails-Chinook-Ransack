module Search
  class Track < Search::Base

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
                  props_lambda = lambda do |helper|
                    {
                      placeholder: get_translate_key('select_tracks'),
                      filter_url: helper.get_index_url_for_model(:track, format: :json),
                    }
                  end

                  props_lambda
                end
              },
              {
                name: 'name', type: 'text_field',
                ransack_field_name: 'name_cont',
                label: get_translate_key('name')
              },
              {
                name: 'composer', type: 'text_field',
                ransack_field_name: 'composer_cont',
                label: get_translate_key('composer')
              },
              {
                name: 'milliseconds_between', type: 'range_number_field',
                ransack_field_name: 'milliseconds_between',
                label: get_translate_key('milliseconds_between'),
                fiter_label: get_translate_key('milliseconds')
              },
              {
                name: 'bytes_between', type: 'range_number_field',
                ransack_field_name: 'bytes_between',
                label: get_translate_key('bytes_between'),
                fiter_label: get_translate_key('bytes')
              },
              {
                name: 'unit_price_between', type: 'range_number_field',
                ransack_field_name: 'unit_price_between',
                label: get_translate_key('unit_price_between'),
                fiter_label: get_translate_key('unit_price')
              },
              {
                name: 'name_or_composer_contains', type: 'text_field',
                ransack_field_name: 'name_or_composer_cont',
                label: get_translate_key('name_or_composer_contains')
              },
              {
                name: 'album_or_genre_or_media_type_contains', type: 'text_field',
                ransack_field_name: 'album_title_or_genre_name_or_media_type_name_cont',
                label: get_translate_key('album_or_genre_or_media_type_contains')
              },
              {
                name: 'album_ids', type: 'remote_select_field',
                ransack_field_name: 'album_id_in',
                label: get_translate_key('by_albums'),
                props: lambda do |helper|
                  props_lambda = lambda do |helper|
                    {
                      placeholder: get_translate_key('select_albums'),
                      filter_url: helper.get_index_url_for_model(:album, format: :json),
                    }
                  end

                  props_lambda
                end
              },
              {
                name: 'genre_ids', type: 'remote_select_field',
                ransack_field_name: 'genre_id_in',
                label: get_translate_key('by_genres'),
                props: lambda do |helper|
                  props_lambda = lambda do |helper|
                    {
                      placeholder: get_translate_key('select_genres'),
                      filter_url: helper.get_index_url_for_model(:genre, format: :json),
                    }
                  end

                  props_lambda
                end
              },
              {
                name: 'media_type_ids', type: 'remote_select_field',
                ransack_field_name: 'media_type_id_in',
                label: get_translate_key('by_media_types'),
                props: lambda do |helper|
                  props_lambda = lambda do |helper|
                    {
                      placeholder: get_translate_key('select_media_types'),
                      filter_url: helper.get_index_url_for_model(:media_type, format: :json),
                    }
                  end

                  props_lambda
                end
              },
              {
                name: 'has_invoices', type: 'boolean_field',
                scope_name: 'has_invoices',
                label: get_translate_key('has_invoices')
              },
              {
                name: 'has_composers', type: 'boolean_field',
                scope_name: 'has_composers',
                label: get_translate_key('has_composers')
              }
            ]
          ],
          [
            get_translate_key('album_fields'),
            [
              {
                name: 'album_title', type: 'text_field',
                ransack_field_name: 'album_title_cont',
                label: get_translate_key('album_title')
              },
            ]
          ],
          [
            get_translate_key('media_type_fields'),
            [
              {
                name: 'media_type_name', type: 'text_field',
                ransack_field_name: 'media_type_name_cont',
                label: get_translate_key('media_type_name')
              },
            ]
          ],
          [
            get_translate_key('genre_fields'),
            [
              {
                name: 'genre_name', type: 'text_field',
                ransack_field_name: 'genre_name_cont',
                label: get_translate_key('genre_name')
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
            name: 'album_title_contains_rock',
            label: get_translate_key('template.album_title_contains_rock_test'),
            filters: [
              from_search_field('album_title', 'Rock'),
            ]
          },
          {
            name: 'album_ids_141_2_and_genre_ids_2', # Greatest Hits and Balls to the Wall, genre Jazz
            label: get_translate_key('template.album_ids_141_2_and_genre_ids_2_test'),
            filters: lambda do |helper|
              [
                from_search_field('album_ids', ['141', '2'], helper),
                from_search_field('genre_ids', ['2'], helper),
              ]
            end
          },
          # test filter templates

          {
            name: 'top_10_tracks_with_most_orders',
            label: get_translate_key('template.top_10_tracks_with_most_orders'),
            filters: lambda do |helper|
              [from_search_field('ids', load_tracks_by_number_invoices(10, true), helper)]
            end
          },
          {
            name: 'top_10_tracks_with_fewest_orders',
            label: get_translate_key('template.top_10_tracks_with_fewest_orders'),
            filters: lambda do |helper|
              [from_search_field('ids', load_tracks_by_number_invoices(10, false), helper)]
            end
          },
          {
            name: 'albums_that_have_25_or_more_tracks',
            label: get_translate_key('template.albums_that_have_25_or_more_tracks'),
            filters: lambda do |helper|
              [from_search_field('album_ids', load_album_by_number_tracks(25, true), helper)]
            end
          },
          {
            name: 'albums_that_have_2_or_fewer_tracks',
            label: get_translate_key('template.albums_that_have_2_or_fewer_tracks'),
            filters: lambda do |helper|
              [from_search_field('album_ids', load_album_by_number_tracks(2, false), helper)]
            end
          },
          {
            name: 'genres_that_have_25_or_more_tracks',
            label: get_translate_key('template.genres_that_have_25_or_more_tracks'),
            filters: lambda do |helper|
              [from_search_field('genre_ids', load_genre_by_number_tracks(20, true), helper)]
            end
          },
          {
            name: 'genres_that_have_15_or_fewer_tracks',
            label: get_translate_key('template.genres_that_have_15_or_fewer_tracks'),
            filters: lambda do |helper|
              [from_search_field('genre_ids', load_genre_by_number_tracks(15, false), helper)]
            end
          },
          {
            name: 'media_type_that_have_250_or_more_tracks',
            label: get_translate_key('template.media_type_that_have_250_or_more_tracks'),
            filters: lambda do |helper|
              [from_search_field('media_type_ids', load_media_type_by_number_tracks(250, true), helper)]
            end
          },
          {
            name: 'media_type_that_have_10_or_fewer_tracks',
            label: get_translate_key('template.media_type_that_have_10_or_fewer_tracks'),
            filters: lambda do |helper|
              [from_search_field('media_type_ids', load_media_type_by_number_tracks(10, false), helper)]
            end
          },
          {
            name: 'top_10_tracks_with_longest_duration',
            label: get_translate_key('template.top_10_tracks_with_longest_duration'),
            filters: lambda do |helper|
              [from_search_field('ids', load_tracks_by_durations(10, true), helper)]
            end
          },
          {
            name: 'top_10_tracks_with_shortest_duration',
            label: get_translate_key('template.top_10_tracks_with_shortest_duration'),
            filters: lambda do |helper|
              [from_search_field('ids', load_tracks_by_durations(10, false), helper)]
            end
          },
          {
            name: 'top_10_tracks_with_most_bytes',
            label: get_translate_key('template.top_10_tracks_with_most_bytes'),
            filters: lambda do |helper|
              [from_search_field('ids', load_tracks_by_bytes(10, true), helper)]
            end
          },
          {
            name: 'top_10_tracks_with_fewest_bytes',
            label: get_translate_key('template.top_10_tracks_with_fewest_bytes'),
            filters: lambda do |helper|
              [from_search_field('ids', load_tracks_by_bytes(10, false), helper)]
            end
          },
          {
            name: 'tracks_with_no_invoices',
            label: get_translate_key('template.tracks_with_no_invoices'),
            filters: [
              {
                name: 'has_invoices',
                value: false
              }
            ]
          },
          {
            name: 'tracks_with_no_composers',
            label: get_translate_key('template.tracks_with_no_composers'),
            filters: [
              {
                name: 'has_composers',
                value: false
              }
            ]
          },
          {
            name: 'tracks_by_composers_steve_harris_or_robert_plant', # Steve Harris or Robert Plant
            label: get_translate_key('template.tracks_by_composers_steve_harris_or_robert_plant'),
            filters: lambda do |helper|
              [
                from_search_field('composer', ['Steve Harris', 'Robert Plant'], helper)
              ]
            end
          }
        ] + base_template_fields
      end

      def model
        'Track'
      end

      def load_tracks_by_number_invoices(num = 10, is_top = true)
        if is_top
          ids = ::Track.top_tracks_with_most_orders(num)
        else
          ids = ::Track.top_tracks_with_fewest_orders(num)
        end

        result = get_collection_by_model_ids(:track, ids.keys)
        result.each do |record|
          total_invoices = ids.find { |id, _| id == record.last }&.last
          record[0] = "#{record[0]} - #{pluralize(total_invoices, 'invoice')}"
        end

        result
      end

      def load_tracks_by_durations(num = 10, is_top = true)
        if is_top
          ids = ::Track.top_tracks_with_longest_duration(num)
        else
          ids = ::Track.top_tracks_with_shortest_duration(num)
        end

        result = get_collection_by_model_ids(:track, ids.keys)
        result.each do |record|
          total_seconds = ids.find { |id, _| id == record.last }&.last
          record[0] = "#{record[0]} - #{pluralize(total_seconds, 'second')}"
        end

        result
      end

      def load_tracks_by_bytes(num = 10, is_top = true)
        if is_top
          ids = ::Track.top_tracks_with_most_bytes(num)
        else
          ids = ::Track.top_tracks_with_fewest_bytes(num)
        end

        result = get_collection_by_model_ids(:track, ids.keys)
        result.each do |record|
          total_bytes = ids.find { |id, _| id == record.last }&.last
          record[0] = "#{record[0]} - #{pluralize(total_bytes, 'byte')}"
        end

        result
      end

      [:album, :genre, :media_type].each do |model|
        define_method("load_#{model}_by_number_tracks") do |num = 10, is_top = true|
          if is_top
            ids = ::Track.send("top_#{model}_ids_with_most_tracks", num)
          else
            ids = ::Track.send("top_#{model}_ids_with_fewest_tracks", num)
          end

          result = get_collection_by_model_ids(model, ids.keys)
          result.each do |record|
            total_tracks = ids.find { |id, _| id == record.last }&.last
            record[0] = "#{record[0]} - #{pluralize(total_tracks, 'track')}"
          end

          result
        end
      end
    end
  end
end
