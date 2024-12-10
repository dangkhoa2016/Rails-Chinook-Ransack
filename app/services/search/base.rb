module Search
  class Base
    def self.get_translate_key(key)
      if respond_to?(:model)
        "filters.#{model.to_s.underscore.singularize}.#{key}"
      else
        raise NotImplementedError, 'You must implement the model method in your subclass'
      end
    end

    def self.model
      raise NotImplementedError, 'You must implement the model method'
    end

    def self.search_fields
      []
    end

    def self.get_filter_field_names
      search_fields.map { |field| field[:name] }
    end
  end
end
