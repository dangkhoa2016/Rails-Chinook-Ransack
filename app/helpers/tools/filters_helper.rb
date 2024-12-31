module Tools
  module FiltersHelper
    def get_index_url_for_model(model, format: :html)
      if model.blank?
        return ''
      end

      model = model.to_s.underscore.pluralize
      if model == 'support_reps' || model == 'reporting_tos'
        model = 'employees'
      end

      if format == :json
        path = "json_list_for_select_element_#{model}_path"
      else
        path = "#{model}_path"
      end

      if respond_to?(path)
        send(path)
      else
        '#'
      end
    end

    def search_fields_for_select(model)
      if model.blank?
        return ''
      end

      service = get_filter_service(model)
      if service.nil?
        return
      end

      select_options = generate_select_options(service.search_fields, :label, :name)
      if is_group_options(select_options)
        grouped_options_for_select(select_options)
      else
        options_for_select(select_options)
      end
    end

    def filter_templates_for_select(model)
      if model.blank?
        return ''
      end

      service = get_filter_service(model)
      if service.nil?
        return
      end

      select_options = generate_select_options(service.filter_templates, :label, :name)
      options_for_select(select_options)
    end

    def generate_select_options(data, label_method = :first, value_method = :last)
      if data.blank?
        return []
      end

      data.map do |group|
        process_group(group, label_method, value_method)
      end
    end

    def get_filters_from_template_for_form(list_of_templates, model)
      service = get_filter_service(model)
      if service.nil?
        return []
      end
      
      filter_list = []
      templates = list_of_templates.split(',')

      templates.each do |template|
        filters = service.get_filters_from_template(template, self)
        if filters.present?
          filters.each do |filter|
            filter_list << filter
          end
        end
      end

      filters = []
      filter_list.each do |item|
        filter = if item[:name].blank? && item[:field_name].present?
          item
        else
          service.get_params_to_render_filter_with_value(item[:name], item[:value], self)
        end

        filters << filter if filter.present?
      end

      filters
    end

    def get_filters_for_form(list_of_filters, model)
      service = get_filter_service(model)
      if service.nil?
        return []
      end

      names = list_of_filters.split(',')
      filters = []

      names.each do |name|
        filter = service.get_params_to_render_filter_with_value(name, nil, self)
        if filter.present?
          filters << filter
        end
      end

      filters
    end

    private

    def get_filter_service(model)
      if model.blank?
        return
      end

      "Search::#{model.to_s.underscore.classify}".constantize rescue nil
    end

    def process_group(group, label_method = :first, value_method = :last)
      if group.is_a?(Array)
        group_name = translate(group.first)

        group_data = group.last.select { |filter| filter[:show] != false }.map do |item|
          process_group(item, label_method, value_method)
        end
        [group_name, group_data]
      elsif group.is_a?(Hash)
        label = get_value(group, label_method)
        value = get_value(group, value_method)
        [translate(label), value]
      end
    end

    def get_value(item, field_method)
      if item.blank? || field_method.blank?
        return ''
      end

      if item.respond_to?(field_method)
        item.send(field_method)
      elsif !item.is_a?(Array) && item[field_method]
        item[field_method]
      else
        item.send(:first)
      end
    end

    def is_group_options(options)
      options.all? do |option|
        if option.is_a?(Array)
          option.last.is_a?(Array)
        else
          false
        end
      end
    end
  end
end
