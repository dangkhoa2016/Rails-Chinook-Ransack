module Search
  class Customer < Search::Base

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
                    placeholder: get_translate_key('select_customers'),
                    filter_url: helper.get_index_url_for_model(:customer, format: :json),
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
                name: 'company', type: 'text_field',
                ransack_field_name: 'company_cont',
                label: get_translate_key('company')
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
                name: 'number_of_invoices_between', type: 'range_number_field',
                scope_name: 'with_invoices_count_in_range',
                fiter_label: get_translate_key('number_of_invoices'),
                label: get_translate_key('number_of_invoices_between')
              },
              {
                name: 'has_invoices', type: 'boolean_field',
                scope_name: 'has_invoices',
                label: get_translate_key('has_invoices')
              },
            ]
          ],
          [
            get_translate_key('support_rep_fields'),
            [
              {
                name: 'support_rep_name', type: 'text_field',
                ransack_field_name: 'support_rep_first_name_or_support_rep_last_name_cont',
                label: get_translate_key('support_rep_name')
              },
              {
                name: 'support_rep_ids', type: 'remote_select_field',
                ransack_field_name: 'support_rep_id_in',
                label: get_translate_key('by_support_rep'),
                props: lambda do |helper|
                  props_lambda = lambda do |helper|
                    {
                      placeholder: get_translate_key('select_employee'),
                      filter_url: helper.get_index_url_for_model(:employee, format: :json),
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
            name: 'support_by_employee_peacok_jane', # Peacock Jane
            label: get_translate_key('template.support_by_employee_name_peacok_jane_test'),
            filters: [
              {
                name: 'support_rep_ids',
                value: [3]
              }
            ]
          },
          # test filter templates

          {
            name: 'customers_have_more_than_or_equal_to_7_invoices',
            label: get_translate_key('template.customers_have_more_than_or_equal_to_7_invoices'),
            filters: lambda do |helper|
              [from_search_field('ids', load_customers_by_number_invoices(7, true), helper)]
            end
          },
          {
            name: 'customers_have_fewer_than_or_equal_to_4_invoices',
            label: get_translate_key('template.customers_have_fewer_than_or_equal_to_4_invoices'),
            filters: lambda do |helper|
              [from_search_field('ids', load_customers_by_number_invoices(4, false), helper)]
            end
          },
          {
            name: 'customers_with_no_invoices',
            label: get_translate_key('template.customers_with_no_invoices'),
            filters: [
              {
                name: 'has_invoices',
                value: false
              }
            ]
          },
          {
            name: 'customers_in_brazil',
            label: get_translate_key('template.customers_in_brazil'),
            filters: [
              {
                name: 'country',
                value: 'Brazil'
              }
            ]
          },
          {
            name: 'customers_in_brazil_or_usa',
            label: get_translate_key('template.customers_in_brazil_or_usa'),
            filters: [
              {
                name: 'country',
                value: 'Brazil;USA'
              }
            ]
          }
        ] + base_template_fields
      end

      def model
        'Customer'
      end

      def load_customers_by_number_invoices(num = 10, is_top = true)
        if is_top
          ids = ::Invoice.customers_ids_with_most_invoices(num)
        else
          ids = ::Invoice.customers_ids_with_fewest_invoices(num)
        end

        result = get_collection_by_model_ids(:customer, ids.keys)
        result.each do |record|
          count_invoices = ids.find { |id, _| id == record.last }&.last
          record[0] = "#{record[0]} - #{pluralize(count_invoices, 'invoice')}"
        end

        result
      end

      def get_model_class(model)
        model = model.to_s.gsub(/_ids\z/, '')
        model = 'Employee' if model == 'support_rep'

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
