module DisplayHelper
  def display_columns(klass)
    return [] unless klass
    columns = klass.respond_to?(:display_columns) ? klass.display_columns : klass.column_names
    columns.map do |column|
      if column.is_a?(String)
        { field: column }
      else
        column
      end
    end
  end

  def render_columns(record)
    columns = display_columns(get_model_class(record)).select do |column|
      column[:only_in_form] != true
    end

    columns.map do |column|
      value = record.send(column[:field])
      render_wrapper do
        if block_given?
          capture(column, value) do
            yield(column, value)
          end
        else
          render_default(column, value, record)
        end
      end
    end.join.html_safe
  end

  def get_label(field, klass)
    if klass && klass.respond_to?(:human_attribute_name)
      klass.human_attribute_name(field)
    else
      I18n.translate!(field) rescue field.to_s.titleize
    end
  end

  def get_model_class(record)
    if record.is_a?(String)
      return record.classify.constantize rescue nil
    end

    if record.respond_to?(:class)
      record.class
    elsif record.respond_to?(:klass)
      record.klass
    end
  end

  def render_default(column, value, record)
    column = { field: column } if column.is_a?(String)
    klass = get_model_class(record)
    content_tag(:strong, get_label(column[:field], klass)) + ': ' +
      render_value(column, value, klass.columns_hash[column[:field].to_s]&.type)
  end

  def render_wrapper(&block)
    content_tag(:div, class: 'col') do
      content_tag(:p, class: 'mb-0') do
        yield
      end
    end
  end

  def render_value(column, value, type = nil)
    if column[:type] == 'association'
      render_association(value)
    else
      if type == :decimal
        render_decimal_value(value)
      else
        value.to_s
      end
    end
  end

  def render_decimal_value(value)
    number_to_currency(value, locale: 'en')
  end

  def render_association(record)
    if record.nil?
      "No association"
    else
      link_to(record)
    end
  end
end
