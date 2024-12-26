module Search
    class Artist < Search::Base
  
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
                      placeholder: get_translate_key('select_artists'),
                      filter_url: helper.get_index_url_for_model(:artist, format: :json),
                    }
                  end
                },
                {
                  name: 'name', type: 'text_field',
                  ransack_field_name: 'name_cont',
                  label: get_translate_key('name')
                },
                {
                  name: 'number_of_albums_between', type: 'range_number_field',
                  scope_name: 'with_albums_count_in_range',
                  fiter_label: get_translate_key('number_of_albums'),
                  label: get_translate_key('number_of_albums_between')
                },
                {
                  name: 'has_albums', type: 'boolean_field',
                  scope_name: 'has_albums',
                  label: get_translate_key('has_albums')
                }
              ]
            ],

            base_timestamp_fields
          ]
        end
  
        def filter_templates
          [
            # test filter templates
            {
              name: 'by_artist_pearl_jam',
              label: get_translate_key('template.by_artist_id_118_test'), # by artist id 118 is Pearl Jam
              filters: lambda do |helper|
                [from_search_field('ids', get_collection_by_model_ids(:artist, [118]), helper)]
              end
            },
            # test filter templates
  
            {
              name: 'artists_have_more_than_or_equal_to_10_albums',
              label: get_translate_key('template.artists_have_more_than_or_equal_to_10_albums'),
              filters: lambda do |helper|
                [from_search_field('ids', load_artists_by_number_albums(10, true), helper)]
              end
            },
            {
              name: 'artists_have_fewer_than_or_equal_to_1_albums',
              label: get_translate_key('template.artists_have_fewer_than_or_equal_to_1_albums'),
              filters: lambda do |helper|
                [from_search_field('ids', load_artists_by_number_albums(1, false), helper)]
              end
            },
            {
              name: 'artists_with_no_albums',
              label: get_translate_key('template.artists_with_no_albums'),
              filters: lambda do |helper|
                [from_search_field('has_albums', false, helper)]
              end
            }
          ] + base_template_fields
        end
  
        def model
          'Artist'
        end
  
        def load_artists_by_number_albums(num = 10, is_top = true)
          if is_top
            ids = ::Artist.artist_ids_with_most_albums(num)
          else
            ids = ::Artist.artist_ids_with_fewest_albums(num)
          end
  
          result = get_collection_by_model_ids(:artist, ids.keys)
          result.each do |record|
            count_albums = ids.find { |id, _| id == record.last }&.last
            record[0] = "#{record[0]} - #{pluralize(count_albums, 'album')}"
          end
  
          result
        end
      end
    end
  end
  