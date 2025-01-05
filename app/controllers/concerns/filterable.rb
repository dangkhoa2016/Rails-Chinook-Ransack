module Filterable
  extend ActiveSupport::Concern

  included do
    before_action :load_filters, only: [:index]
    
    def render_index(mode = 'card')
      if request.query_parameters['partial_only'] == 'true'
        request.query_parameters.delete('partial_only')
        render partial: 'shared/index_records', locals: { mode: mode }
      else
        render :index
      end
    end
  end

  def filter_service
    "Search::#{controller_name.classify}".constantize rescue nil
  end

  def load_filters
    params = request.query_parameters
    if params.blank?
      return
    end

    if params[:q].present?
      @filters = { default_ransack_params => params[:q] }
      return
    end

    service = filter_service
    if service.nil?
      return
    end

    @filter_list = service.get_filters_from_query(params, self.view_context)
    if @filter_list.blank?
      return
    end

    filter_params = {}
    @filter_list.map do |filter|
      if filter[:scope_name].present?
        filter_params.merge!(scope_name: { filter[:scope_name] => filter[:field_value] })
        next
      end

      if filter[:ransack_field_name].end_with?('_between')
        name = filter[:ransack_field_name].gsub('_between', '')
        values = filter[:field_value]
        if values.is_a?(String)
          values = values.split(/[,;]/).map(&:strip).compact
          if values.size == 2
            values = { min_value: values[0], max_value: values[1] }
          else
            values = { min_value: values[0], max_value: values[0] }
          end
          filter[:field_value] = values
        end
        filter_params.merge!("#{name}_gteq" => values[:min_value], "#{name}_lteq" => values[:max_value])
        next
      end

      if filter_params[filter[:ransack_field_name]].blank?
        filter_params.merge!(filter[:ransack_field_name] => filter[:field_value])
      elsif filter_service.is_csv_field?(filter[:field_name])
        values = filter[:field_value].compact
        values.each do |value|
          filter_params[filter[:ransack_field_name]] << value
        end
      else
        if filter_params[filter[:ransack_field_name]].is_a?(Array)
          # filter_params[filter[:ransack_field_name]] += filter[:field_value]
          filter_params[filter[:ransack_field_name]] = filter[:field_value]
          filter_params[filter[:ransack_field_name]].uniq!
        end
      end
    end

    @filters = filter_params
  end

  def process_filters(query)
    new_filters = {}
    if @filters.present?
      @filters.each do |key, value|
        if key.to_s == 'scope_name'
          scope_info = value.to_a.first
          if scope_info.last.is_a?(Hash)
            query = query.send(scope_info.first, *scope_info.last.values)
          else
            query = query.send(scope_info.first, scope_info.last)
          end

          next
        end

        new_filters[key] = value
      end
    end

    pagy(query.ransack(new_filters).result.order(sorting_params), limit: page_size)
  end



  def sorting_params
    { sort_column => sort_direction }
  end

  def page_size
    (cookies[:per_page].presence || Pagy::DEFAULT[:limit]).to_i
  end
end
