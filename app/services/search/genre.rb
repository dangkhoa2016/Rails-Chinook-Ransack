module Search
	class Genre < Search::Base

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
										placeholder: get_translate_key('select_genres'),
										filter_url: helper.get_index_url_for_model(:genre, format: :json),
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
						name: 'genre_name_contains_nova', # Genre name contains Nova
						label: get_translate_key('template.genre_name_contains_nova_test'),
						filters: [
							{
								name: 'name',
								value: 'Nova'
							}
						]
					},
					{
						name: 'by_genre_id_2', # Genre name is Jazz
						label: get_translate_key('template.by_genre_id_2_test'),
						filters: lambda do |helper|
							[
								from_search_field('ids', [2], helper),
							].flatten.compact
						end
					},
					# test filter templates

					{
						name: 'genres_have_more_than_or_equal_to_100_tracks',
						label: get_translate_key('template.genres_have_more_than_or_equal_to_100_tracks'),
						filters: lambda do |helper|
							[from_search_field('ids', load_genres_by_number_tracks(100, true), helper)]
						end
					},
					{
						name: 'genres_have_fewer_than_or_equal_to_30_tracks',
						label: get_translate_key('template.genres_have_fewer_than_or_equal_to_30_tracks'),
						filters: lambda do |helper|
							[from_search_field('ids', load_genres_by_number_tracks(30, false), helper)]
						end
					},
          {
            name: 'genres_with_no_tracks',
            label: get_translate_key('template.genres_with_no_tracks'),
            filters: [
              {
                name: 'has_tracks',
                value: false
              }
            ]
          }
				] + base_template_fields
			end

			def model
				'Genre'
			end

			def load_genres_by_number_tracks(num = 10, is_top = true)
				if is_top
					ids = ::Genre.genre_ids_with_most_tracks(num)
				else
					ids = ::Genre.genre_ids_with_fewest_tracks(num)
				end

				result = get_collection_by_model_ids(:genre, ids.keys)
				result.each do |record|
					count_tracks = ids.find { |id, _| id == record.last }&.last
					record[0] = "#{record[0]} - #{pluralize(count_tracks, 'track')}"
				end

				result
			end
		end
	end
end
