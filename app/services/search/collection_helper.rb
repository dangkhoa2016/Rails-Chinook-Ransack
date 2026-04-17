module Search
  module CollectionHelper
    def get_collection_by_model_ids(model, ids, includes = nil)
      return [] if ids.blank? || model.blank?

      model_class = get_model_class(model)
      return [] unless model_class

      records = model_class.includes(includes).where(id: ids)
      ids.map do |id|
        record = records.find { |r| r.id.to_s == id.to_s }
        [get_display_name(record, includes), record.id]
      end
    end

    def get_model_class(model)
      model = model.to_s.gsub(/_ids\z/, '')
      "::#{model.classify}".constantize rescue nil
    end

    def get_display_name(record, _includes = nil)
      return '' unless record.present?

      %i[name title full_name display_name].each do |method|
        return record.public_send(method) if record.respond_to?(method)
      end

      record.to_s
    end

    def parse_date_range_between(combined_date)
      return if combined_date.blank?
      return { min_value: combined_date[0], max_value: combined_date[1] } if combined_date.is_a?(Array)

      dates = combined_date.split(/[,;]+/).compact
      return if dates.empty?

      date_hash = {}
      if dates[0].present? && valid_date_format?(dates[0])
        date = Date.parse(dates[0]) rescue nil
        date_hash[:min_value] = format_date(date) if date
      end

      if dates[1].present? && valid_date_format?(dates[1])
        date = Date.parse(dates[1]) rescue nil
        if date
          date_hash[:min_value] ||= nil
          date_hash[:max_value] = format_date(date)
        end
      end

      date_hash
    end

    def parse_number_range_between(combined_number)
      return if combined_number.blank?
      return { min_value: combined_number[0], max_value: combined_number[1] } if combined_number.is_a?(Array)

      numbers = combined_number.split(/[ ,;]+/).compact
      return if numbers.empty?

      number_hash = {}
      number_hash[:min_value] = numbers[0].to_i if numbers[0].present? && valid_number_format?(numbers[0])

      if numbers[1].present? && valid_number_format?(numbers[1])
        number_hash[:min_value] ||= nil
        number_hash[:max_value] = numbers[1].to_i
      end

      number_hash
    end

    def valid_date_format?(str)
      str.match?(/^\d{1,2}[-\/]\d{1,2}[-\/]\d{4}$/) ||
        str.match?(/^\d{4}[-\/]\d{1,2}[-\/]\d{1,2}$/) ||
        str.match?(/^\d{1,2}\s+[A-Za-z0-9\.]{3,9}\s+\d{4}$/)
    end

    def valid_number_format?(str)
      str.match?(/^\d+([.,]+\d+)?$/) && (str.count('.') <= 1 || str.count(',') <= 1)
    end

    def format_date(date)
      return if date.blank?
      date.strftime('%Y-%m-%d')
    end
  end
end
