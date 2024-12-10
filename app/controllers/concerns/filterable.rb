module Filterable
  extend ActiveSupport::Concern

  included do
    before_action :load_filters, only: [:index]
  end

  def filter_service
    "Search::#{controller_name.classify}".constantize rescue nil
  end

  def get_filters_from_query
    params = request.query_parameters
    if params.blank?
      return
    end

    if params[:q].present?
      return { default_ransack_params => params[:q] }
    end

    service = filter_service
    if service.nil?
      return
    end

    @filter_list = service.get_filters_from_query(params, nil)
    if @filter_list.blank?
      return
    end

    filter_params = {}
    @filter_list.map do |filter|
      if filter[:ransack_field_name].end_with?('_between')
        name = filter[:ransack_field_name].gsub('_between', '')
        values = filter[:field_value]
        filter_params.merge!("#{name}_gteq" => values[:from], "#{name}_lteq" => values[:to])
      elsif filter_params[filter[:ransack_field_name]].blank?
        filter_params.merge!(filter[:ransack_field_name] => filter[:field_value])
      else
        if filter_params[filter[:ransack_field_name]].is_a?(Array)
          filter_params[filter[:ransack_field_name]] += filter[:field_value]
          filter_params[filter[:ransack_field_name]].uniq!
        end
      end
    end

    filter_params
  end

  def load_filters
    @filters = get_filters_from_query
  end
end
