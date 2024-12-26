module Search
  class Invoice < Search::Base
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
                      placeholder: get_translate_key('select_invoices'),
                      filter_url: helper.get_index_url_for_model(:invoice, format: :json),
                    }
                  end

                  props_lambda
                end
              },
              {
                name: 'billing_address', type: 'text_field',
                ransack_field_name: 'billing_address_cont',
                label: get_translate_key('billing_address')
              },
              {
                name: 'billing_city', type: 'text_field',
                ransack_field_name: 'billing_city_cont',
                label: get_translate_key('billing_city')
              },
              {
                name: 'billing_state', type: 'text_field',
                ransack_field_name: 'billing_state_cont',
                label: get_translate_key('billing_state')
              },
              {
                name: 'billing_country', type: 'text_field',
                ransack_field_name: 'billing_country_cont',
                label: get_translate_key('billing_country')
              },
              {
                name: 'billing_postal_code', type: 'text_field',
                ransack_field_name: 'billing_postal_code_cont',
                label: get_translate_key('billing_postal_code')
              },
              {
                name: 'billing_address_or_billing_country_contains', type: 'text_field',
                ransack_field_name: 'billing_address_or_billing_country_cont',
                label: get_translate_key('billing_address_or_billing_country_contains')
              },
              {
                name: 'billing_city_or_billing_postal_code_contains', type: 'text_field',
                ransack_field_name: 'billing_city_or_billing_postal_code_cont',
                label: get_translate_key('billing_city_or_billing_postal_code_contains')
              },
              {
                name: 'number_of_invoice_lines_between', type: 'range_number_field',
                scope_name: 'with_invoice_lines_count_in_range',
                fiter_label: get_translate_key('number_of_invoice_lines'),
                label: get_translate_key('number_of_invoice_lines_between')
              },
              {
                name: 'total_between', type: 'range_number_field',
                ransack_field_name: 'total_between',
                label: get_translate_key('total_between')
              }
            ]
          ],
          [
            get_translate_key('customer_fields'),
            [
              {
                name: 'customer_name', type: 'text_field',
                ransack_field_name: 'customer_first_name_or_customer_last_name_cont',
                label: get_translate_key('customer_name')
              },
              {
                name: 'customer_ids', type: 'remote_select_field',
                ransack_field_name: 'customer_id_in',
                label: get_translate_key('by_customers'),
                props: lambda do |helper|
                  props_lambda = lambda do |helper|
                    {
                      placeholder: get_translate_key('select_customers'),
                      filter_url: helper.get_index_url_for_model(:customer, format: :json),
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
            name: 'by_customer_leonie_khler', # Leonie Khler
            label: get_translate_key('template.by_customer_leonie_khler_test'),
            filters: [
              {
                name: 'customer_ids',
                value: [2]
              }
            ]
          },
          # test filter templates

          {
            name: 'invoices_more_than_or_equal_to_10_tracks',
            label: get_translate_key('template.invoices_more_than_or_equal_to_10_tracks'),
            filters: lambda do |helper|
              [from_search_field('ids', load_invoices_by_number_tracks(10, true), helper)]
            end
          },
          {
            name: 'invoices_fewer_than_or_equal_to_2_tracks', type: 'select_field',
            label: get_translate_key('template.invoices_fewer_than_or_equal_to_2_tracks'),
            filters: lambda do |helper|
              [from_search_field('ids', load_invoices_by_number_tracks(2, false), helper)]
            end
          },
          {
            name: 'top_10_invoices_with_highest_total_price',
            label: get_translate_key('template.top_10_invoices_with_highest_total_price'),
            filters: lambda do |helper|
              [from_search_field('ids', load_invoices_by_total_price(10, true), helper)]
            end
          },
          {
            name: 'top_10_invoices_with_lowest_total_price',
            label: get_translate_key('template.top_10_invoices_with_lowest_total_price'),
            filters: lambda do |helper|
              [from_search_field('ids', load_invoices_by_total_price(10, false), helper)]
            end
          },
          {
            name: 'customers_have_more_than_or_equal_to_7_invoices',
            label: get_translate_key('template.customers_have_more_than_or_equal_to_7_invoices'),
            filters: lambda do |helper|
              [from_search_field('customer_ids', load_customers_by_number_invoices(7, true), helper)]
            end
          },
          {
            name: 'customers_have_fewer_than_or_equal_to_4_invoices',
            label: get_translate_key('template.customers_have_fewer_than_or_equal_to_4_invoices'),
            filters: lambda do |helper|
              [from_search_field('customer_ids', load_customers_by_number_invoices(4, false), helper)]
            end
          }
        ] + base_template_fields
      end

      def model
        'Invoice'
      end

      def load_invoices_by_number_tracks(num = 10, is_top = true)
        if is_top
          ids = ::Invoice.invoice_ids_with_most_tracks(num)
        else
          ids = ::Invoice.invoice_ids_with_fewest_tracks(num)
        end

        result = get_collection_by_model_ids(:invoice, ids.keys)
        result.each do |record|
          total_tracks = ids.find { |id, _| id == record.last }&.last
          record[0] = "#{record[0]} - #{pluralize(total_tracks, 'track')}"
        end

        result
      end

      def load_invoices_by_total_price(num = 10, is_top = true)
        if is_top
          ids = ::Invoice.top_most_expensive_invoice_ids(num)
        else
          ids = ::Invoice.top_fewest_expensive_invoice_ids(num)
        end

        result = get_collection_by_model_ids(:invoice, ids.keys)
        result.each do |record|
          total_price = ids.find { |id, _| id == record.last }&.last
          record[0] = "#{record[0]} - $#{total_price}"
        end

        result
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

      def get_display_name(record, includes = nil)
        unless record.present?
          return ''
        end

        if record.is_a?(::Invoice)
          "ID: #{record.id}"
        else
          record.full_name
        end
      end
    end
  end
end
