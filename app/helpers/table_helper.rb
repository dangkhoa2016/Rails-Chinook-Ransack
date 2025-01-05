module TableHelper

  def sort_arrow(is_sorting, direction)
    if !is_sorting
      return content_tag(:i, '', class: 'ms-1 bi bi-arrows-vertical')
    end

    if sort_direction_asc?
      content_tag(:i, '', class: 'ms-1 bi bi-caret-down-fill')
    elsif sort_direction_desc?
      content_tag(:i, '', class: 'ms-1 bi bi-caret-up-fill')
    end
  end

  def build_sort_link(column, klass = nil)
    link_method = method("#{controller_name}_path")
    direction = sort_direction_param(column)
    is_sorting = is_current_sort_column?(column)
    query_params = request.query_parameters.except(:sort, :direction, :page)
    url = link_method.call(query_params.merge(sort: column, direction: direction))

    column_name = column.to_s.titleize
    unless klass.present?
      klass = controller_name.classify.constantize rescue nil
    end
    column_name = klass.human_attribute_name(column) if klass.present?

    link_to url, class: "sort-link#{ is_sorting ? '' : ' text-dark' }" do
      "#{column_name}#{sort_arrow(is_sorting, direction)}".html_safe
    end
  end
end
