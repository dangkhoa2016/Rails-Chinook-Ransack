module Search
  class Base
    class << self
      include ActionView::Helpers::TextHelper
      CSV_FIELDS = %w[country state city address postal_code first_name last_name composer].freeze

      def get_translate_key(key, common = false)
        if common
          "filters.common.#{key}"
        elsif respond_to?(:model)
          "filters.#{model.to_s.underscore.singularize}.#{key}"
        else
          raise NotImplementedError, 'You must implement the model method in your subclass'
        end
      end

      def model
        raise NotImplementedError, 'You must implement the model method'
      end

      def search_fields
        []
      end
      
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
          {
            name: 'created_at_this_year',
            label: get_translate_key('template.created_at_this_year', true),
            filters: lambda do |helper|
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
          #   label: get_translate_key('template.created_at_this_month', true),
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
            label: get_translate_key('template.created_at_this_month', true),
            filters: lambda do |helper|
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
            label: get_translate_key('template.created_at_this_week', true),
            filters: lambda do |helper|
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
            label: get_translate_key('template.created_at_today', true),
            filters: lambda do |helper|
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
            label: get_translate_key('template.updated_at_this_year', true),
            filters: lambda do |helper|
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
            label: get_translate_key('template.updated_at_this_month', true),
            filters: lambda do |helper|
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
            label: get_translate_key('template.updated_at_this_week', true),
            filters: lambda do |helper|
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
            label: get_translate_key('template.updated_at_today', true),
            filters: lambda do |helper|
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
            label: get_translate_key('template.created_at_this_year_and_updated_at_this_month', true),
            filters: lambda do |helper|
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
            label: get_translate_key('template.created_at_this_month_and_updated_at_this_week', true),
            filters: lambda do |helper|
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
            label: get_translate_key('template.created_at_this_week_and_updated_at_today', true),
            filters: lambda do |helper|
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
            label: get_translate_key('template.created_at_today_and_updated_at_today', true),
            filters: lambda do |helper|
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


      # helper methods

      def is_csv_field?(field)
        CSV_FIELDS.include?(field)
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
          props_lambda = filter[:props].call(helper)
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
          props[:collection] = collection.presence || []
        end

        {
          field_name: filter_field,
          field_label: filter[:fiter_label].presence || filter[:label],
          field_type: filter[:type],
          field_props: props,
          field_value: filter[:value],
          ransack_field_name: filter[:ransack_field_name],
          scope_name: filter[:scope_name]
        }
      end

      def get_params_to_render_filter_with_value(filter_field, value, helper)
        filter = get_params_to_render_filter(filter_field, helper)
        if filter.blank?
          return
        end

        if filter[:field_name].start_with?('has_') && value.is_a?(String)
          value = value.to_yes_no
        end

        if filter[:field_type] == 'remote_select_field' && helper.present?
          value = value.split(',') if value.is_a?(String)

          if value.is_a?(Array) && value.first.is_a?(Array)
            filter[:field_props].merge!(collection: value)
          else
            model_name = filter[:field_name] == 'ids' ? self.model : filter[:field_name]
            
            filter[:field_props].merge!(collection: get_collection_by_model_ids(model_name, value))
          end
        end

        if filter[:field_name].to_s.end_with?('_between')
          result = parse_date_range_between(value) rescue nil
          if result.blank?
            result = parse_number_range_between(value) rescue nil
          end

          result = {} if result.blank?
          value = result
        elsif filter[:field_type] == 'remote_select_field'
          value = value.map(&:last) if value.is_a?(Array) && value.first.is_a?(Array)
        elsif is_csv_field?(filter[:field_name])
          value = value.split(';') if value.is_a?(String)
          filter[:ransack_field_name] = filter[:ransack_field_name].gsub('_cont', '_cont_any')
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

      def get_filters_from_template(template, helper)
        filter_template = filter_templates.find { |f| f[:name] == template }
        if filter_template.blank?
          return []
        end

        if filter_template[:filters].respond_to?(:call) # lambda
          filter_template[:filters].call(helper)
        else
          filter_template[:filters]
        end
      end

      def parse_date_range_between(combined_date)
        return if combined_date.blank?
        if combined_date.is_a?(Array)
          return { min_value: combined_date[0], max_value: combined_date[1] }
        end

        dates = combined_date.split(/[,;]+/).compact

        if dates.size == 0
          return
        end

        date_hash = {}
        date = nil
        if dates.size > 0 && dates[0].present? && valid_date_format?(dates[0])
          date = Date.parse(dates[0]) rescue nil
          date_hash[:min_value] = format_date(date) if date
        end

        date = nil
        if dates.size > 1 && dates[1].present? && valid_date_format?(dates[1])
          date = Date.parse(dates[1]) rescue nil
          if date
            date_hash[:min_value] = nil unless date_hash.key?(:min_value)
            date_hash[:max_value] = format_date(date)
          end
        end

        date_hash
      end

      def parse_number_range_between(combined_number)
        return if combined_number.blank?
        if combined_number.is_a?(Array)
          return { min_value: combined_number[0], max_value: combined_number[1] }
        end

        numbers = combined_number.split(/[ ,;]+/).compact

        if numbers.size == 0
          return
        end

        number_hash = {}
        if numbers.size > 0 && numbers[0].present? && valid_number_format?(numbers[0])
          number_hash[:min_value] = numbers[0].to_i
        end

        if numbers.size > 1 && numbers[1].present? && valid_number_format?(numbers[1])
          value = numbers[1].to_i
          if value
            number_hash[:min_value] = nil unless number_hash.key?(:min_value)
            number_hash[:max_value] = value
          end
        end

        number_hash
      end

      def valid_date_format?(str)
        str.match?(/^\d{1,2}[-\/]\d{1,2}[-\/]\d{4}$/) || str.match?(/^\d{4}[-\/]\d{1,2}[-\/]\d{1,2}$/) || 
        str.match?(/^\d{1,2}\s+[A-Za-z0-9\.]{3,9}\s+\d{4}$/)
      end

      def valid_number_format?(str)
        str.match?(/^\d+([.,]+\d+)?$/) && (str.count('.') <= 1 || str.count(',') <= 1)
      end

      def from_search_field(field, value, helper = nil)
        get_params_to_render_filter_with_value(field, value, helper)
      end

      def from_template(template, helper)
        filters = get_filters_from_template(template, helper)
        return if filters.blank?

        filters.map do |filter|
          if filter[:field_name]
            filter
          else
            from_search_field(filter[:name], filter[:value], helper)
          end
        end
      end

      def format_date(date)
        return if date.blank?
        date.strftime('%Y-%m-%d')
      end

      def get_collection_by_model_ids(model, ids, includes = nil)
        if ids.blank?
          return []
        end

        if model.blank?
          return []
        end

        model_class = get_model_class(model)
        return [] unless model_class

        records = model_class.includes(includes).where(id: ids)
        ids.map do |id|
          record = records.find { |r| r.id.to_s == id.to_s }
          [get_display_name(record, includes), record.id]
        end
      end

      def get_model_class(model)
        model = model.to_s.gsub(/_ids\z/, '')
        "::#{model.classify}".constantize rescue nil
      end

      def get_display_name(record, includes = nil)
        if record.respond_to?(:name)
          return record.name
        end
        
        if record.respond_to?(:title)
          return record.title
        end

        if record.respond_to?(:full_name)
          return record.full_name
        end

        if record.respond_to?(:display_name)
          return record.display_name
        end
      end

      # helper methods
    end
  end
end
