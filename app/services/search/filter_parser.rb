module Search
  module FilterParser
    def get_filters_from_query(params, helper)
      return [] if params.blank?

      params.filter_map do |k, v|
        get_params_to_render_filter_with_value(k, v, helper)
      end
    end

    def get_filters_from_template(template, helper)
      filter_template = filter_templates.find { |f| f[:name] == template }
      return [] if filter_template.blank?

      if filter_template[:filters].respond_to?(:call)
        filter_template[:filters].call(helper)
      else
        filter_template[:filters]
      end
    end

    def get_params_to_render_filter(filter_field, helper)
      return if filter_field.blank?

      filter = get_search_field(filter_field)
      return if filter.blank?

      props = resolve_props(filter, helper)
      props[:collection] = resolve_collection(filter) if filter[:collection].present?

      {
        field_name:         filter_field,
        field_label:        filter[:fiter_label].presence || filter[:label],
        field_type:         filter[:type],
        field_props:        props,
        field_value:        filter[:value],
        ransack_field_name: filter[:ransack_field_name],
        scope_name:         filter[:scope_name]
      }
    end

    def get_params_to_render_filter_with_value(filter_field, value, helper)
      filter = get_params_to_render_filter(filter_field, helper)
      return if filter.blank?

      value = cast_boolean_value(filter, value)
      value = resolve_remote_select_value(filter, value, helper) if filter[:field_type] == 'remote_select_field'
      value = parse_between_value(filter, value)               if filter[:field_name].to_s.end_with?('_between')
      value = apply_csv_field(filter, value)                   if is_csv_field?(filter[:field_name])

      filter.merge(field_value: value)
    end

    def from_search_field(field, value, helper = nil)
      get_params_to_render_filter_with_value(field, value, helper)
    end

    def from_template(template, helper)
      filters = get_filters_from_template(template, helper)
      return if filters.blank?

      filters.map do |filter|
        filter[:field_name] ? filter : from_search_field(filter[:name], filter[:value], helper)
      end
    end

    private

    def resolve_props(filter, helper)
      return {} if filter[:props].blank? || helper.blank?

      result = filter[:props].call(helper)
      result.respond_to?(:call) ? result.call(helper) : result
    end

    def resolve_collection(filter)
      result = filter[:collection].call
      result.respond_to?(:call) ? result.call : result
    end

    def cast_boolean_value(filter, value)
      if filter[:field_name].start_with?('has_') && value.is_a?(String)
        value.to_yes_no
      else
        value
      end
    end

    def resolve_remote_select_value(filter, value, helper)
      value = value.split(',') if value.is_a?(String)

      if value.is_a?(Array) && value.first.is_a?(Array)
        filter[:field_props].merge!(collection: value)
        value.map(&:last)
      else
        model_name = filter[:field_name] == 'ids' ? self.model : filter[:field_name]
        collection = get_collection_by_model_ids(model_name, value)
        filter[:field_props].merge!(collection: collection)
        value
      end
    end

    def parse_between_value(filter, value)
      result = parse_date_range_between(value) rescue nil
      result = parse_number_range_between(value) rescue nil if result.blank?
      result.presence || {}
    end

    def apply_csv_field(filter, value)
      value = value.split(';') if value.is_a?(String)
      filter[:ransack_field_name] = filter[:ransack_field_name].gsub('_cont', '_cont_any')
      value
    end
  end
end
