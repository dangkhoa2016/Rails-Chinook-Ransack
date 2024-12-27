module Search
	class InvoiceLine < Search::Base

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
										placeholder: get_translate_key('select_invoice_lines'),
										filter_url: helper.get_index_url_for_model(:invoice_line, format: :json),
									}
								end
							},
						]
					],
					[
						get_translate_key('customer_fields'),
						[
							{
								name: 'by_customer_name', type: 'text_field',
								ransack_field_name: 'invoice_customer_first_name_or_invoice_customer_last_name_cont',
								label: get_translate_key('by_customer_name')
							},
							{
                name: 'customer_ids', type: 'remote_select_field',
								scope_name: 'by_customer_ids',
                label: get_translate_key('by_customer_ids'),
                props: lambda do |helper|
                  props_lambda = lambda do |helper|
                    {
                      placeholder: get_translate_key('select_customers'),
                      filter_url: helper.get_index_url_for_model(:customer, format: :json),
                    }
                  end

                  props_lambda
                end
              },
						]
					],
					[
            get_translate_key('track_fields'),
						[
							{
								name: 'track_ids', type: 'remote_select_field',
								ransack_field_name: 'track_id_in',
								label: get_translate_key('by_track_ids'),
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
								name: 'track_name', type: 'text_field',
								ransack_field_name: 'track_name_cont',
								label: get_translate_key('by_track_name')
							},
							{
								name: 'track_composer', type: 'text_field',
								ransack_field_name: 'track_composer_cont',
								label: get_translate_key('track_composer')
							},
							{
								name: 'track_bytes_between', type: 'range_number_field',
								ransack_field_name: 'track_bytes_between',
								label: get_translate_key('track_bytes_between'),
								fiter_label: get_translate_key('track_bytes')
							},
							{
								name: 'track_milliseconds_between', type: 'range_number_field',
								ransack_field_name: 'track_milliseconds_between',
								label: get_translate_key('track_milliseconds_between'),
								fiter_label: get_translate_key('track_miliseconds')
							},
							{
								name: 'track_unit_price_between', type: 'range_number_field',
								ransack_field_name: 'track_unit_price_between',
								label: get_translate_key('track_unit_price_between'),
								fiter_label: get_translate_key('track_unit_price')
							},
						]
					],
					[
						get_translate_key('invoice_fields'),
						[
							{
								name: 'invoice_ids', type: 'remote_select_field',
								ransack_field_name: 'invoice_id_in',
								label: get_translate_key('by_invoices'),
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
						]
					],

					base_timestamp_fields
				]
			end

			def filter_templates
				[
					# test filter templates
					{
						name: 'track_name_contains_nova', # Track name contains Nova
						label: get_translate_key('template.track_name_contains_nova_test'),
						filters: [
							{
								name: 'track_name',
								value: 'Nova'
							}
						]
					},
					{
						name: 'by_invoice_id_5_and_12_and_created_at_this_year',
						label: get_translate_key('template.by_invoice_id_5_and_12_and_created_at_this_year_test'),
						filters: lambda do |helper|
							[
								from_search_field('invoice_ids', [5, 12], helper),
								from_template('created_at_this_year', helper)
							].flatten.compact
						end
					},
					{
						name: 'by_cusomer_kara_nielsen',
						label: get_translate_key('template.by_cusomer_kara_nielsen_test'),
						filters: lambda do |helper|
							[
								from_search_field('customer_ids', [9], helper)
							].flatten.compact
						end
					}
					# test filter templates

				] + base_template_fields
			end

			def model
				'InvoiceLine'
			end

      def get_display_name(record, includes = nil)
        unless record.present?
          return ''
        end

        if record.is_a?(::Customer)
          record.full_name
        else
          "ID: #{record.id}"
        end
      end

      # helper methods
		end
	end
end
