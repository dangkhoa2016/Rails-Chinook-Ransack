module Search
    class MediaType < Search::Base
  
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
                      placeholder: get_translate_key('select_media_types'),
                      filter_url: helper.get_index_url_for_model(:media_type, format: :json),
                    }
                  end
                },
                {
                  name: 'name', type: 'text_field',
                  ransack_field_name: 'name_cont',
                  label: get_translate_key('name')
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
              name: 'by_name_mpeg_audio_file',
              label: get_translate_key('template.by_name_mpeg_audio_file_test'),
              filters: [
                {
                  name: 'name',
                  value: 'MPEG audio file'
                }
              ]
            },
            # test filter templates
  
            {
              name: 'media_types_have_more_than_or_equal_to_500_tracks',
              label: get_translate_key('template.media_types_have_more_than_or_equal_to_500_tracks'),
              filters: lambda do |helper|
                [from_search_field('ids', load_media_types_by_number_tracks(500, true), helper)]
              end
            },
            {
              name: 'media_types_have_fewer_than_or_equal_to_250_tracks',
              label: get_translate_key('template.media_types_have_fewer_than_or_equal_to_250_tracks'),
              filters: lambda do |helper|
                [from_search_field('ids', load_media_types_by_number_tracks(250, false), helper)]
              end
            },
            {
              name: 'media_types_with_no_tracks',
              label: get_translate_key('template.media_types_with_no_tracks'),
              filters: lambda do |helper|
                [from_search_field('has_tracks', false, helper)]
              end
            }
          ] + base_template_fields
        end
  
        def model
          'MediaType'
        end
  
        def load_media_types_by_number_tracks(num = 10, is_top = true)
          if is_top
            ids = ::MediaType.media_type_ids_with_most_tracks(num)
          else
            ids = ::MediaType.media_type_ids_with_fewest_tracks(num)
          end
  
          result = get_collection_by_model_ids(:media_type, ids.keys)
          result.each do |record|
            count_tracks = ids.find { |id, _| id == record.last }&.last
            record[0] = "#{record[0]} - #{pluralize(count_tracks, 'track')}"
          end
  
          result
        end
      end
    end
  end
  