module Search
  module FieldDefinitions
    def base_timestamp_fields
      [
        get_translate_key('timestamp_fields', true),
        [
          {
            name: 'created_at_from', type: 'date_field',
            label: get_translate_key('created_at_from', true),
            ransack_field_name: 'created_at_gteq'
          },
          {
            name: 'created_at_to', type: 'date_field',
            label: get_translate_key('created_at_to', true),
            ransack_field_name: 'created_at_lteq'
          },
          {
            name: 'updated_at_from', type: 'date_field',
            label: get_translate_key('updated_at_from', true),
            ransack_field_name: 'updated_at_gteq'
          },
          {
            name: 'updated_at_to', type: 'date_field',
            label: get_translate_key('updated_at_to', true),
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
            label: get_translate_key('created_at_or_updated_at_between', true),
            ransack_field_name: 'created_at_or_updated_at_between',
            fiter_label: get_translate_key('created_at_or_updated_at', true)
          },
          {
            name: 'created_at_between', type: 'range_date_field',
            label: get_translate_key('created_at_between', true),
            ransack_field_name: 'created_at_between',
            fiter_label: get_translate_key('created_at', true)
          },
          {
            name: 'updated_at_between', type: 'range_date_field',
            label: get_translate_key('updated_at_between', true),
            ransack_field_name: 'updated_at_between',
            fiter_label: get_translate_key('updated_at', true)
          }
        ]
      ]
    end

    def base_template_fields
      [
        date_range_template('created_at_this_year',  Time.now.beginning_of_year,  Time.now.end_of_year),
        date_range_template('created_at_this_month', Time.now.beginning_of_month, Time.now.end_of_month),
        date_range_template('created_at_this_week',  Time.now.beginning_of_week,  Time.now.end_of_week),
        date_range_template('created_at_today',      Time.now,                    Time.now),
        date_range_template('updated_at_this_year',  Time.now.beginning_of_year,  Time.now.end_of_year,  :updated_at_between),
        date_range_template('updated_at_this_month', Time.now.beginning_of_month, Time.now.end_of_month, :updated_at_between),
        date_range_template('updated_at_this_week',  Time.now.beginning_of_week,  Time.now.end_of_week,  :updated_at_between),
        date_range_template('updated_at_today',      Time.now,                    Time.now,              :updated_at_between),
        combined_date_range_template('created_at_this_year_and_updated_at_this_month',
          [Time.now.beginning_of_year,  Time.now.end_of_year],
          [Time.now.beginning_of_month, Time.now.end_of_month]
        ),
        combined_date_range_template('created_at_this_month_and_updated_at_this_week',
          [Time.now.beginning_of_month, Time.now.end_of_month],
          [Time.now.beginning_of_week,  Time.now.end_of_week]
        ),
        combined_date_range_template('created_at_this_week_and_updated_at_today',
          [Time.now.beginning_of_week, Time.now.end_of_week],
          [Time.now,                   Time.now]
        ),
        combined_date_range_template('created_at_today_and_updated_at_today',
          [Time.now, Time.now],
          [Time.now, Time.now]
        )
      ]
    end

    private

    def date_range_template(name, from, to, field = :created_at_between)
      {
        name: name,
        label: get_translate_key("template.#{name}", true),
        filters: lambda do |helper|
          [from_search_field(field, [format_date(from), format_date(to)])]
        end
      }
    end

    def combined_date_range_template(name, created_range, updated_range)
      {
        name: name,
        label: get_translate_key("template.#{name}", true),
        filters: lambda do |helper|
          [
            from_search_field(:created_at_between, created_range.map { |d| format_date(d) }),
            from_search_field(:updated_at_between, updated_range.map { |d| format_date(d) })
          ].flatten.compact
        end
      }
    end
  end
end
