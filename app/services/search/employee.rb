module Search
  class Employee < Search::Base

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
                    placeholder: get_translate_key('select_employees'),
                    filter_url: helper.get_index_url_for_model(:employee, format: :json),
                  }
                end
              },
              {
                name: 'first_name', type: 'text_field',
                ransack_field_name: 'first_name_cont',
                label: get_translate_key('first_name')
              },
              {
                name: 'last_name', type: 'text_field',
                ransack_field_name: 'last_name_cont',
                label: get_translate_key('last_name')
              },
              {
                name: 'title', type: 'text_field',
                ransack_field_name: 'title_cont',
                label: get_translate_key('title')
              },
              {
                name: 'address', type: 'text_field',
                ransack_field_name: 'address_cont',
                label: get_translate_key('address')
              },
              {
                name: 'city', type: 'text_field',
                ransack_field_name: 'city_cont',
                label: get_translate_key('city')
              },
              {
                name: 'state', type: 'text_field',
                ransack_field_name: 'state_cont',
                label: get_translate_key('state')
              },
              {
                name: 'country', type: 'text_field',
                ransack_field_name: 'country_cont',
                label: get_translate_key('country')
              },
              {
                name: 'postal_code', type: 'text_field',
                ransack_field_name: 'postal_code_cont',
                label: get_translate_key('postal_code')
              },
              {
                name: 'phone', type: 'text_field',
                ransack_field_name: 'phone_cont',
                label: get_translate_key('phone')
              },
              {
                name: 'fax', type: 'text_field',
                ransack_field_name: 'fax_cont',
                label: get_translate_key('fax')
              },
              {
                name: 'email', type: 'text_field',
                ransack_field_name: 'email_cont',
                label: get_translate_key('email')
              },
              {
                name: 'first_name_or_last_name_contains', type: 'text_field',
                ransack_field_name: 'first_name_or_last_name_cont',
                label: get_translate_key('first_name_or_last_name_contains')
              },
              {
                name: 'city_or_state_or_country_contains', type: 'text_field',
                ransack_field_name: 'city_or_state_or_country_cont',
                label: get_translate_key('city_or_state_or_country_contains')
              },
              {
                name: 'number_of_customers_between', type: 'range_number_field',
                scope_name: 'with_customers_count_in_range',
                fiter_label: get_translate_key('number_of_customers'),
                label: get_translate_key('number_of_customers_between')
              },
              {
                name: 'number_of_subordinates_between', type: 'range_number_field',
                scope_name: 'with_subordinates_count_in_range',
                fiter_label: get_translate_key('number_of_subordinates'),
                label: get_translate_key('number_of_subordinates_between')
              },
              {
                name: 'has_customers', type: 'boolean_field',
                ransack_field_name: 'has_customers',
                label: get_translate_key('has_customers')
              },
              {
                name: 'has_subordinates', type: 'boolean_field',
                ransack_field_name: 'has_subordinates',
                label: get_translate_key('has_subordinates')
              }
            ]
          ],
          [
            get_translate_key('reporting_to_fields'),
            [
              {
                name: 'name_of_report_to', type: 'text_field',
                ransack_field_name: 'reporting_to_first_name_or_reporting_to_last_name_cont',
                label: get_translate_key('name_of_report_to')
              },
              {
                name: 'ids_of_report_to', type: 'remote_select_field',
                ransack_field_name: 'reporting_to_id_in',
                label: get_translate_key('ids_of_report_to'),
                props: lambda do |helper|
                  props_lambda = lambda do |helper|
                    {
                      placeholder: get_translate_key('select_employees'),
                      filter_url: helper.get_index_url_for_model(:employee, format: :json),
                    }
                  end

                  props_lambda
                end
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
            name: 'reporting_to_manager_edwards_nancy', # Edwards nancy
            label: get_translate_key('template.reporting_to_manager_name_peacok_nancy_test'),
            filters: [
              {
                name: 'ids_of_report_to',
                value: [2]
              }
            ]
          },
          # test filter templates

          {
            name: 'employees_have_more_than_or_equal_to_3_subordinates',
            label: get_translate_key('template.employees_have_more_than_or_equal_to_3_subordinates'),
            filters: lambda do |helper|
              [from_search_field('ids', load_employees_by_number_subordinates(3, true), helper)]
            end
          },
          {
            name: 'employees_have_fewer_than_or_equal_to_2_subordinates',
            label: get_translate_key('template.employees_have_fewer_than_or_equal_to_2_subordinates'),
            filters: lambda do |helper|
              [from_search_field('ids', load_employees_by_number_subordinates(2, false), helper)]
            end
          },
          {
            name: 'employees_have_more_than_or_equal_to_21_customers',
            label: get_translate_key('template.employees_have_more_than_or_equal_to_21_customers'),
            filters: lambda do |helper|
              [from_search_field('ids', load_employees_by_number_customers(21, true), helper)]
            end
          },
          {
            name: 'employees_have_fewer_than_or_equal_to_20_customers',
            label: get_translate_key('template.employees_have_fewer_than_or_equal_to_20_customers'),
            filters: lambda do |helper|
              [from_search_field('ids', load_employees_by_number_customers(20, false), helper)]
            end
          },
          {
            name: 'employees_with_no_customers',
            label: get_translate_key('template.employees_with_no_customers'),
            filters: [
              {
                name: 'has_customers',
                value: false
              }
            ]
          },
          {
            name: 'employees_with_no_subordinates',
            label: get_translate_key('template.employees_with_no_subordinates'),
            filters: [
              {
                name: 'has_subordinates',
                value: false
              }
            ]
          },
          {
            name: 'employees_in_calgary_city',
            label: get_translate_key('template.employees_in_calgary_city'),
            filters: [
              {
                name: 'city',
                value: 'Calgary'
              }
            ]
          },
          {
            name: 'employees_in_edmonton_or_lethbridge_city', # Edmonton or Lethbridge
            label: get_translate_key('template.employees_in_edmonton_or_lethbridge_city'),
            filters: [
              {
                name: 'city',
                value: 'Edmonton;Lethbridge'
              }
            ]
          }
        ] + base_template_fields
      end

      def model
        'Employee'
      end

      def load_employees_by_number_subordinates(num = 10, is_top = true)
        if is_top
          ids = ::Employee.employees_ids_with_most_subordinates(num)
        else
          ids = ::Employee.employees_ids_with_fewest_subordinates(num)
        end

        result = get_collection_by_model_ids(:employee, ids.keys)
        result.each do |record|
          count_subordinates = ids.find { |id, _| id == record.last }&.last
          record[0] = "#{record[0]} - #{pluralize(count_subordinates, 'subordinate')}"
        end

        result
      end

      def load_employees_by_number_customers(num = 10, is_top = true)
        if is_top
          ids = ::Employee.employees_ids_with_most_customers(num)
        else
          ids = ::Employee.employees_ids_with_fewest_customers(num)
        end

        result = get_collection_by_model_ids(:employee, ids.keys)
        result.each do |record|
          count_customers = ids.find { |id, _| id == record.last }&.last
          record[0] = "#{record[0]} - #{pluralize(count_customers, 'customer')}"
        end

        result
      end

      def get_model_class(model)
        model = model.to_s.gsub(/_ids\z/, '')
        model = 'Employee' if model == 'reports_to'

        "::#{model.classify}".constantize rescue nil
      end

      def get_display_name(record, includes = nil)
        unless record.present?
          return ''
        end

        record.full_name
      end
    end
  end
end
