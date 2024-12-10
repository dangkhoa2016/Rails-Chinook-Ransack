module Search
  class Album < Search::Base

    class << self
      def search_fields
        [
          [
            get_translate_key('model_fields'),
            [
              {
                name: 'title', type: 'text_field',
                ransack_field_name: 'title_cont',
                label: get_translate_key('album_title')
              },
              {
                name: 'album_or_artist_contains', type: 'text_field',
                ransack_field_name: 'title_or_artist_name_cont',
                label: get_translate_key('album_or_artist_contains')
              }
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
                name: 'most_popular_artist_ids', type: 'select_field',
                ransack_field_name: 'artist_id_in',
                label: get_translate_key('most_popular_artists'),
                props: lambda do
                  {
                    placeholder: get_translate_key('select_artists'),
                  }
                end,
                collection: lambda { load_most_popular_artists(10) }
              },
              {
                name: 'artist_ids', type: 'remote_select_field',
                ransack_field_name: 'artist_id_in',
                label: get_translate_key('belong_to_artists'),
                props: lambda do
                  props_lambda = lambda do |helper|
                    {
                      placeholder: get_translate_key('select_artists'),
                      filter_url: helper.get_index_url_for_model('Artist', format: :json),
                    }
                  end

                  props_lambda
                end
              }
            ]
          ],
          [
            get_translate_key('timestamp_fields'),
            [
              {
                name: 'created_at_from', type: 'date_field',
                label: get_translate_key('created_at_from'),
                ransack_field_name: 'created_at_gteq'
              },
              {
                name: 'created_at_to', type: 'date_field',
                label: get_translate_key('created_at_to'),
                ransack_field_name: 'created_at_lteq'
              },
              {
                name: 'updated_at_from', type: 'date_field',
                label: get_translate_key('updated_at_from'),
                ransack_field_name: 'updated_at_gteq'
              },
              {
                name: 'updated_at_to', type: 'date_field',
                label: get_translate_key('updated_at_to'),
                ransack_field_name: 'updated_at_lteq'
              },
              {
                name: 'created_at_or_updated_at_from', type: 'date_field',
                ransack_field_name: 'created_at_or_updated_at_gteq',
                show: false
              },
              {
                name: 'created_at_or_updated_at_to', type: 'date_field',
                ransack_field_name: 'created_at_or_updated_at_lteq',
                show: false
              },
              {
                name: 'created_at_or_updated_at_between', type: 'range_date_field',
                label: get_translate_key('created_at_or_updated_at_between'),
                ransack_field_name: 'created_at_or_updated_at_between',
                fiter_label: get_translate_key('created_at_or_updated_at')
              },
              {
                name: 'created_at_between', type: 'range_date_field',
                label: get_translate_key('created_at_between'),
                ransack_field_name: 'created_at_between',
                fiter_label: get_translate_key('created_at')
              },
              {
                name: 'updated_at_between', type: 'range_date_field',
                label: get_translate_key('updated_at_between'),
                ransack_field_name: 'updated_at_between',
                fiter_label: get_translate_key('updated_at')
              }
            ]
          ]
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
            name: 'by_artist_name_accept_and_created_at_this_year',
            label: get_translate_key('template.by_artist_name_accept_and_created_at_this_year_test'),
            filters: lambda do
              [
                from_search_field('artist_name', 'Accept'),
                from_template('created_at_this_year')
              ].flatten.compact
            end
          },
          {
            name: 'by_artist_id_118', # Pearl Jam
            label: get_translate_key('template.by_artist_id_118_test'),
            filters: lambda do
              [
                from_search_field('artist_ids', [118])
              ]
            end
          },
          # test filter templates

          {
            name: 'created_at_this_year',
            label: get_translate_key('template.created_at_this_year'),
            filters: lambda do
              [
                from_search_field(:created_at_between, [
                  format_date(Time.now.beginning_of_year),
                  format_date(Time.now.end_of_year)
                ])
              ]
            end
          },


          # these lines still working
          # {
          #   name: 'created_at_this_month',
          #   label: get_translate_key('template.created_at_this_month'),
          #   filters: lambda do
          #     [{
          #     name: 'created_at_from',
          #       value: Time.now.beginning_of_month.iso8601
          #     }, {
          #       name: 'created_at_to',
          #       value: Time.now.end_of_month.iso8601
          #     }]
          #   end
          # },

          # new way
          {
            name: 'created_at_this_month',
            label: get_translate_key('template.created_at_this_month'),
            filters: lambda do
              [
                from_search_field(:created_at_between, [
                  format_date(Time.now.beginning_of_month),
                  format_date(Time.now.end_of_month)
                ])
              ]
            end
          },


          {
            name: 'created_at_this_week',
            label: get_translate_key('template.created_at_this_week'),
            filters: lambda do
              [
                from_search_field(:created_at_between, [
                  format_date(Time.now.beginning_of_week),
                  format_date(Time.now.end_of_week)
                ])
              ]
            end
          },
          {
            name: 'created_at_today',
            label: get_translate_key('template.created_at_today'),
            filters: lambda do
              [
                from_search_field(:created_at_between, [
                  format_date(Time.now),
                  format_date(Time.now)
                ])
              ]
            end
          },
          {
            name: 'updated_at_this_year',
            label: get_translate_key('template.updated_at_this_year'),
            filters: lambda do
              [
                from_search_field(:updated_at_between, [
                  format_date(Time.now.beginning_of_year),
                  format_date(Time.now.end_of_year)
                ])
              ]
            end
          },
          {
            name: 'updated_at_this_month',
            label: get_translate_key('template.updated_at_this_month'),
            filters: lambda do
              [
                from_search_field(:updated_at_between, [
                  format_date(Time.now.beginning_of_month),
                  format_date(Time.now.end_of_month)
                ])
              ]
            end
          },
          {
            name: 'updated_at_this_week',
            label: get_translate_key('template.updated_at_this_week'),
            filters: lambda do
              [
                from_search_field(:updated_at_between, [
                  format_date(Time.now.beginning_of_week),
                  format_date(Time.now.end_of_week)
                ])
              ]
            end
          },
          {
            name: 'updated_at_today',
            label: get_translate_key('template.updated_at_today'),
            filters: lambda do
              [
                from_search_field(:updated_at_between, [
                  format_date(Time.now),
                  format_date(Time.now)
                ])
              ]
            end
          },
          {
            name: 'created_at_this_year_and_updated_at_this_month',
            label: get_translate_key('template.created_at_this_year_and_updated_at_this_month'),
            filters: lambda do
              [
                from_search_field(:created_at_between, [
                  format_date(Time.now.beginning_of_year),
                  format_date(Time.now.end_of_year)
                ]),
                from_search_field(:updated_at_between, [
                  format_date(Time.now.beginning_of_month),
                  format_date(Time.now.end_of_month)
                ])
              ].flatten.compact
            end
          },
          {
            name: 'created_at_this_month_and_updated_at_this_week',
            label: get_translate_key('template.created_at_this_month_and_updated_at_this_week'),
            filters: lambda do
              [
                from_search_field(:created_at_between, [
                  format_date(Time.now.beginning_of_month),
                  format_date(Time.now.end_of_month)
                ]),
                from_search_field(:updated_at_between, [
                  format_date(Time.now.beginning_of_week),
                  format_date(Time.now.end_of_week)
                ])
              ].flatten.compact
            end
          },
          {
            name: 'created_at_this_week_and_updated_at_today',
            label: get_translate_key('template.created_at_this_week_and_updated_at_today'),
            filters: lambda do
              [
                from_search_field(:created_at_between, [
                  format_date(Time.now.beginning_of_week),
                  format_date(Time.now.end_of_week)
                ]),
                from_search_field(:updated_at_between, [
                  format_date(Time.now),
                  format_date(Time.now)
                ])
              ].flatten.compact
            end
          },
          {
            name: 'created_at_today_and_updated_at_today',
            label: get_translate_key('template.created_at_today_and_updated_at_today'),
            filters: lambda do
              [
                from_search_field(:created_at_between, [
                  format_date(Time.now),
                  format_date(Time.now)
                ]),
                from_search_field(:updated_at_between, [
                  format_date(Time.now),
                  format_date(Time.now)
                ])
              ].flatten.compact
            end
          }
        ]
      end

      def model
        'Album'
      end

      def load_most_popular_artists(has_more_than_albums = 5)
        ids = ::Album.top_most_popular_artist_ids(has_more_than_albums)
        get_collection_by_ids(ids)
      end

      def get_collection_by_ids(ids)
        ::Artist.where(id: ids).map { |artist| [artist.name, artist.id] }
      end
      
      def get_search_field(key)
        search_fields.each do |group|
          group[1].each do |field|
            if field[:name] == key.to_s
              return field
            end
          end
        end

        nil
      end

      def get_params_to_render_filter(filter_field, helper)
        if filter_field.blank?
          return
        end

        filter = get_search_field(filter_field)
        if filter.blank?
          return
        end

        props = {}
        if filter[:props].present? && helper.present?
          props_lambda = filter[:props].call
          if props_lambda && props_lambda.respond_to?(:call)
            props = props_lambda.call(helper)
          else
            props = props_lambda
          end
        end

        props ||= {}
        if filter[:collection].present? && helper.present?
          props_lambda = filter[:collection].call
          collection = if props_lambda && props_lambda.respond_to?(:call)
            props_lambda.call(helper)
          else
            props_lambda
          end
          props[:collection] = collection || []
        end

        {
          field_name: filter_field,
          field_label: filter[:fiter_label] || filter[:label],
          field_type: filter[:type],
          field_props: props,
          field_value: filter[:value],
          ransack_field_name: filter[:ransack_field_name]
        }
      end

      def get_params_to_render_filter_with_value(filter_field, value, helper)
        puts "get_params_to_render_filter_with_value: #{filter_field}, #{value}, #{helper}"
        filter = get_params_to_render_filter(filter_field, helper)
        if filter.blank?
          return
        end

        if filter[:field_type] == 'remote_select_field' && helper.present?
          filter[:field_props].merge!(collection: get_collection_by_ids(value))
        end

        if filter[:field_name].to_s.end_with?('_between')
          value = parse_date_range_between(value)
        end

        filter.merge!(field_value: value)
      end

      def get_filters_from_query(params, helper)
        if params.blank?
          return []
        end

        result = []
        params.each do |k, v|
          if filter = get_params_to_render_filter_with_value(k, v, helper)
            result << filter
          end
        end

        result
      end

      def get_filters_from_template(template)
        filter_template = filter_templates.find { |f| f[:name] == template }
        if filter_template.blank?
          return []
        end

        if filter_template[:filters].respond_to?(:call) # lambda
          filter_template[:filters].call
        else
          filter_template[:filters]
        end
      end

      def parse_date_range_between(combined_date)
        return if combined_date.blank?
        if combined_date.is_a?(Array)
          return { from: combined_date[0], to: combined_date[1] }
        end

        dates = combined_date.split(/[ ,;]+/)

        date_hash = { from: nil, to: nil }
        if dates.size > 0
          date = Date.parse(dates[0])
          date_hash[:from] = format_date(date)
        end

        if dates.size > 1
          date = Date.parse(dates[1])
          date_hash[:to] = format_date(date)
        end

        date_hash
      end

      def from_search_field(field, value)
        search_field = get_search_field(field)
        return if search_field.blank?

        search_field.merge!(value: value)
      end

      def from_template(template)
        filters = get_filters_from_template(template)
        return if filters.blank?

        filters.map do |filter|
          from_search_field(filter[:name], filter[:value])
        end
      end

      def format_date(date)
        return if date.blank?
        date.strftime('%Y-%m-%d')
      end
    end
  end
end
